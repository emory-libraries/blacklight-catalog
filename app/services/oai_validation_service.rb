# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'traject'
require 'faraday'
require 'rsolr'
require 'oai_processing/oai_processing_toolset'

class OaiValidationService
  extend OaiProcessingToolset
  MARC_URL = OaiProcessingToolset.const_get(:MARC_URL).freeze
  OAI_URL = OaiProcessingToolset.const_get(:OAI_URL).freeze

  # Validates whether a record should be indexed or not
  # @param record_id [Int] ID of the record
  # @return [Boolean] true if record is valid, false if not
  def self.validate_record(record_id, logger = Logger.new(STDOUT))
    validate_record!(record_id, logger)
    true
  rescue
    false
  end

  # Validates whether a record should be indexed or not
  # @param record_id [Int] ID of the record
  # @return [Boolean] true if record is valid
  def self.validate_record!(record_id, logger = Logger.new(STDOUT))
    qs = OaiQueryStringService.process_query_string(record_id, false, Time.new.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), true)
    oai = call_oai_for_xml(ENV['ALMA'], ENV['INSTITUTION'], qs, logger)
    xml_type = 'GetRecord'
    document = Nokogiri::XML(oai.body)
    rules = OaiValidation::Rule.all_rules(document:, xml_type:)
    rules.each do |rule|
      raise OaiValidationServiceError, "Record ##{record_id} violates the following rule: #{rule.description}" if rule.record_ids.any?
    end
    true
  end
end

class OaiValidationServiceError < StandardError
end
