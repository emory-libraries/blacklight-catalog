# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'traject'
require 'faraday'
require 'rsolr'
require 'oai_processing/oai_processing_toolset'

class OaiProcessingService
  extend OaiProcessingToolset
  MARC_URL = OaiProcessingToolset.const_get(:MARC_URL).freeze
  OAI_URL = OaiProcessingToolset.const_get(:OAI_URL).freeze

  def self.process_oai_with_marc_indexer(institution, qs, alma, logger = Logger.new(STDOUT))
    oai = call_oai_for_xml(alma, institution, qs, logger)
    document = Nokogiri::XML(oai.body)
    # handling of delete records
    deleted_records = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:record[oai:header/@status="deleted"]', OAI_URL)
    suppressed_records = document.xpath("//marc:record[substring(marc:leader, 6, 1)='d']", MARC_URL) # gets all records with `d` in the 6th (actual) position of leader string
    lost_stolen_records = pull_lost_stolen_records(document)
    deactivated_portfolios = pull_deactivated_portfolios(document)
    logger.info "Starting record count: #{document.xpath('//marc:record', MARC_URL).count}"
    deleted_ids = pull_deleted_ids(deleted_records, logger)
    suppressed_ids = pull_suppressed_ids(suppressed_records, logger)
    lost_stolen_ids = pull_lost_stolen_ids(lost_stolen_records, suppressed_ids, logger)
    deact_port_ids = pull_deactivated_portfolios_ids(deactivated_portfolios, suppressed_ids + lost_stolen_ids, logger)
    delete_suppressed_count = (deleted_ids + suppressed_ids + lost_stolen_ids + deact_port_ids).size
    logger.info "Found #{delete_suppressed_count} delete records."

    deleted_records.remove
    suppressed_records.remove
    lost_stolen_records.each(&:remove)
    deactivated_portfolios.each(&:remove)
    record_count = pull_record_count(document, logger)
    if delete_suppressed_count.positive?
      find_and_remove_del_supp_records(
        deleted_ids, suppressed_ids + lost_stolen_ids + deact_port_ids, logger
      )
    end

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

  def self.find_and_remove_del_supp_records(deleted_ids, suppressed_ids, logger)
    solr = RSolr.connect(url: ENV['SOLR_URL'], update_format: :xml, retry_503: 5, retry_after_limit: 5)
    solr.delete_by_id(deleted_ids + suppressed_ids)
    logger.info(solr.commit.to_s)
  end

  def self.process_active_records_from_xml(resumption_token, document, logger)
    filename = Rails.root.join('tmp', "#{resumption_token || 'last'}.xml").to_s
    File.open(filename, "w+") { |f| f.write(Nokogiri::XSLT(oai_to_marc).transform(document).to_s) }

    logger.info "File written to tmp. Now indexing #{filename}"
    ingest_with_traject(filename, logger)
    File.delete(filename)
  end
end
