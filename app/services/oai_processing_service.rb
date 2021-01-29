# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'traject'

class OaiProcessingService
  def self.process_oai_with_marc_indexer(institution, qs, alma)
    process_oai(institution, qs, alma, 'marc_indexer')
  end

  def self.process_oai_with_solr_marc(institution, qs, alma)
    process_oai(institution, qs, alma, 'solr_marc')
  end

  def self.process_oai(institution, qs, alma, ingest_tool)
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
      case ingest_tool
      when 'marc_indexer'
        ingest_with_traject(filename)
      when 'solr_marc'
        ingest_with_solr_marc(filename)
      end
      File.delete(filename)
    end

    # return resumption token at the end by default
    resumption_token
  end

  def self.ingest_with_solr_marc(filename)
    sh "java -Dsolr.hosturl=#{ENV['SOLR_URL']} -jar #{File.dirname(__FILE__)}/solrmarc/solrmarc_core.jar #{File.dirname(__FILE__)}/solrmarc/config.properties \
      -solrj #{File.dirname(__FILE__)}/solrmarc/lib-solrj #{filename}"
  rescue => e
    log e
  end

  def self.ingest_with_traject(filename)
    indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true)
    indexer.load_config_file(Rails.root.join('lib', 'marc_indexer.rb').to_s)
    indexer.process(filename)
  rescue => e
    log e
  end

  def self.oai_to_marc
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

  def self.log(msg)
    time = Time.new.utc
    time = time.strftime("%Y-%m-%d %H:%M:%S")
    puts "#{time} - #{msg}"
    true
  end
end
