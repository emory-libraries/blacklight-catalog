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
  def self.validate_record(record_id, _logger = Logger.new(STDOUT))
    validate_record!(record_id)
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
    document = Nokogiri::XML(oai.body)
    deleted_records = document.xpath("/oai:OAI-PMH/oai:GetRecord/oai:record[oai:header/@status='deleted']", OAI_URL)
    raise OaiValidationServiceError, "Record ##{record_id} is listed under deleted records." if deleted_records.any?
    suppressed_records = document.xpath("//marc:record[substring(marc:leader, 6, 1)='d']", MARC_URL) # gets all records with `d` in the 6th (actual) position of leader string
    raise OaiValidationServiceError, "Record ##{record_id} is listed under suppressed records." if suppressed_records.any?
    lost_stolen_records = pull_lost_stolen_records(document)
    raise OaiValidationServiceError, "Record ##{record_id} is listed under lost/stolen records." if lost_stolen_records.any?
    deactivated_portfolios = pull_deactivated_portfolios(document)
    raise OaiValidationServiceError, "Record ##{record_id} is listed under deactivated portfolio records." if deactivated_portfolios.any?
    temporaries = pull_temp_location_records(document)
    raise OaiValidationServiceError, "Record ##{record_id} is listed under temporarily located records." if temporaries.any?
    true
  end
end

class OaiValidationServiceError < StandardError
end
