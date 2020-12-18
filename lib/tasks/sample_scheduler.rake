# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

desc "Harvest OAI set denoted in ENV oai_set_name and index in Solr"
task oai_harvest: [:environment] do
  oai_set = ENV['oai_set_name']
  abort 'The ENV variable oai_set_name has not been set.' if oai_set.blank?

  log "Starting..."

  from_time = PropertyBag.get('oai_time')
  log "Setting 'from' time: #{from_time}"
  from_time = "&from=#{from_time}" if from_time

  to_time = Time.new.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  log "Set 'to' time: #{to_time}"

  # check where to resume harvesting from
  saved_resumption_token = PropertyBag.get('oai_resumption_token')

  qs = if !saved_resumption_token.to_s == ''
         # resume from last harvested
         "?verb=ListRecords&resumptionToken=#{saved_resumption_token}"
       else
         # start fresh harvest
         "?verb=ListRecords&set=#{oai_set}&metadataPrefix=marc21&until=#{to_time}#{from_time}"
       end

  loop do
    # expect resumption token to be returned from process_oai method, else
    # it will be set to blank
    resumption_token = process_oai(ENV["institution"], qs, ENV["alma"])
    qs = "?verb=ListRecords&resumptionToken=#{resumption_token}"
    PropertyBag.set('oai_resumption_token', resumption_token)
    break if resumption_token == ''
  end

  # save to date for next time
  log "Storing 'to' time"
  PropertyBag.set('oai_time', to_time)

  log "Complete!"
end

def process_oai(institution, qs, alma)
  oai_base = "https://#{alma}.alma.exlibrisgroup.com/view/oai/#{institution}/request"

  log "Calling OAI with query string: #{qs}"
  oai = RestClient.get oai_base + qs

  document = Nokogiri::XML(oai)

  # handling of delete records
  deleted_records = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:record[oai:header/@status="deleted"]', { 'oai' => 'http://www.openarchives.org/OAI/2.0/' })
  log "Found #{deleted_records.count} delete records."

  if deleted_records.count.positive?
    deleted_ids = deleted_records.map { |n| n.at('header/identifier').text.split(':').last }
    deleted_records.remove
    puts RestClient.post "#{ENV['SOLR_URL']}/update?commit=true",
                         "<delete><id>#{deleted_ids.join('</id><id>')}</id></delete>",
                         content_type: :xml
  end

  # Index remaining necessary records
  record_count = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:record', { 'oai' => 'http://www.openarchives.org/OAI/2.0/' }).count
  log "#{record_count} records retrieved"

  resumption_token = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:resumptionToken', { 'oai' => 'http://www.openarchives.org/OAI/2.0/' }).text

  if record_count.positive?
    template = Nokogiri::XSLT(oai_to_marc)
    file = Rails.root.join('tmp', resumption_token || 'last')
    filename = "#{file}.xml"
    File.open(filename, "w+") do |f|
      f.write(template.transform(document).to_s)
    end

    log "File written to tmp. Now indexing #{filename}"
    begin
      sh "java -Dsolr.hosturl=#{ENV['SOLR_URL']} -jar #{File.dirname(__FILE__)}/solrmarc/solrmarc_core.jar #{File.dirname(__FILE__)}/solrmarc/config.properties \
      -solrj #{File.dirname(__FILE__)}/solrmarc/lib-solrj #{filename}"
    rescue => e
      log e
    end
    File.delete(filename)
  end

  # return resumption token at the end by default
  resumption_token
end

def log(msg)
  time = Time.new.utc
  time = time.strftime("%Y-%m-%d %H:%M:%S")
  puts "#{time} - #{msg}"
  true
end

def oai_to_marc
  %q(
  <?xml version='1.0'?>
    <xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:marc="http://www.loc.gov/MARC21/slim">
      <xsl:template match="/">
        <collection>
        <xsl:for-each select="oai:OAI-PMH/oai:ListRecords/oai:record">
          <xsl:copy-of select="oai:metadata/marc:record"/>
        </xsl:for-each>
      </collection>
    </xsl:template>
    </xsl:stylesheet>
  )
end
