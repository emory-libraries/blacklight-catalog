# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'traject'

class OaiProcessingService
  MARC_URL = { 'marc' => "http://www.loc.gov/MARC21/slim" }.freeze
  OAI_URL = { 'oai' => 'http://www.openarchives.org/OAI/2.0/' }.freeze

  def self.process_oai_with_marc_indexer(institution, qs, alma, logger)
    oai = call_oai_for_xml(alma, institution, qs, logger)
    document = Nokogiri::XML(oai.body)
    # handling of delete records
    deleted_records = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:record[oai:header/@status="deleted"]', OAI_URL)
    suppressed_records = document.xpath("//marc:record[substring(marc:leader, 6, 1)='d']", MARC_URL) # gets all records with `d` in the 6th (actual) position of leader string
    delete_suppressed_count = deleted_records.count + suppressed_records.count
    logger.info "Found #{delete_suppressed_count} delete records."
    deleted_ids = pull_deleted_ids(deleted_records, logger)
    suppressed_ids = pull_suppressed_ids(suppressed_records, logger)
    record_count = pull_record_count(document, suppressed_records, logger)
    pull_active_ids(document, suppressed_ids, logger)

    deleted_records.remove
    suppressed_records.remove
    find_and_remove_del_supp_records(deleted_ids, suppressed_ids, logger) if delete_suppressed_count.positive?

    # Index remaining necessary records

    resumption_token = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:resumptionToken', OAI_URL).text

    if record_count.positive?
      begin
        process_active_records_from_xml(resumption_token, document, logger)
      rescue
        return
      end
    end

    # return resumption token at the end by default
    resumption_token
  end

  def self.ingest_with_traject(filename, logger)
    indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true)
    indexer.load_config_file(Rails.root.join('lib', 'marc_indexer.rb').to_s)
    indexer.process(filename)
  rescue => e
    logger.fatal e
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

  def self.find_and_remove_del_supp_records(deleted_ids, suppressed_ids, logger)
    solr = RSolr.connect(url: ENV['SOLR_URL'], update_format: :xml, retry_503: 5, retry_after_limit: 5)
    logger.info(solr.delete_by_id(deleted_ids + suppressed_ids).to_s)
  end

  def self.pull_deleted_ids(deleted_records, logger)
    ids = deleted_records.map { |n| n.at('header/identifier').text.split(':').last }
    logger.info "Deleted IDs: #{ids}"
    ids
  end

  def self.pull_suppressed_ids(suppressed_records, logger)
    # collects ID from controlfield 001
    ids = suppressed_records.map { |s| s.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
    logger.info("Suppressed IDs: #{ids}")
    ids
  end

  def self.pull_active_ids(document, suppressed_ids, logger)
    active_ids_xpath = '/oai:OAI-PMH/oai:ListRecords/oai:record/oai:metadata/marc:record/marc:controlfield[@tag="001"]'
    ids = document.xpath(active_ids_xpath, OAI_URL.dup.merge(MARC_URL)).map(&:content) - [*suppressed_ids]
    logger.info "Active IDs: #{ids}"
    ids
  end

  def self.call_oai_for_xml(alma, institution, qs, logger)
    oai_base = "https://#{alma}.alma.exlibrisgroup.com/view/oai/#{institution}/request"
    oai_connection = Faraday.new do |f|
      f.request :retry, { max: 10, interval: 30, interval_randomness: 0.75, backoff_factor: 2 }
    end

    logger.info "Calling OAI with query string: #{qs}"
    oai_connection.get oai_base + qs
  rescue => err
    ["Communication with the OAI Service failed.", err].each { |m| logger.fatal(m) }
  end

  def self.pull_record_count(document, suppressed_records, logger)
    record_ct = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:record', OAI_URL).count - suppressed_records.count
    logger.info "#{record_ct} records retrieved"
    record_ct
  end

  def self.process_active_records_from_xml(resumption_token, document, logger)
    filename = Rails.root.join('tmp', "#{resumption_token || 'last'}.xml").to_s
    File.open(filename, "w+") { |f| f.write(Nokogiri::XSLT(oai_to_marc).transform(document).to_s) }

    logger.info "File written to tmp. Now indexing #{filename}"
    ingest_with_traject(filename, logger)
    File.delete(filename)
  end
end
