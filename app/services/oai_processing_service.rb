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

  def self.process_oai_with_marc_indexer(institution, qs, alma, single_record, logger = Logger.new(STDOUT))
    oai = call_oai_for_xml(alma, institution, qs, logger)
    document = Nokogiri::XML(oai.body)
    xml_type = single_record ? 'GetRecord' : 'ListRecords'
    rules = OaiValidation::Rule.all_rules(document:, xml_type:)

    # Apply all validation rules
    logger.info "Starting record count: #{document.xpath('//marc:record', MARC_URL).count}"
    invalid_record_ids = []
    rules.each do |rule|
      affected_record_ids = rule.apply
      invalid_record_ids += affected_record_ids
      logger.info "#{rule.name} IDs: #{affected_record_ids}"
    end

    # Remove invalid records from Solr
    invalid_record_ids = invalid_record_ids.uniq
    logger.info "Found #{invalid_record_ids.count} invalid records."
    find_and_remove(invalid_record_ids, logger) if invalid_record_ids.any?

    # Index valid records
    record_count = pull_record_count(document, xml_type, logger)
    resumption_token = document.xpath('/oai:OAI-PMH/oai:ListRecords/oai:resumptionToken', OAI_URL).text

    if record_count.positive?
      begin
        process_active_records_from_xml(resumption_token, document, xml_type, logger)
      rescue
        return
      end
    end

    # return resumption token at the end by default
    resumption_token
  end

  def self.find_and_remove(record_ids, logger)
    solr = RSolr.connect(url: ENV['SOLR_URL'], update_format: :xml, retry_503: 5, retry_after_limit: 5)
    solr.delete_by_id(record_ids)
    logger.info(solr.commit.to_s)
  end

  def self.process_active_records_from_xml(resumption_token, document, xml_type, logger)
    filename = Rails.root.join('tmp', "#{resumption_token.presence || 'last'}.xml").to_s
    File.open(filename, "w+") { |f| f.write(Nokogiri::XSLT(oai_to_marc(xml_type)).transform(document).to_s) }

    logger.info "File written to tmp. Now indexing #{filename}"
    ingest_with_traject(filename, logger)
    File.delete(filename)
  end
end
