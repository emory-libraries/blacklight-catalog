# frozen_string_literal: true

require 'oai_processing/oai_processing_toolset'

class OaiValidation::Rule
  include OaiProcessingToolset
  MARC_URL = OaiProcessingToolset.const_get(:MARC_URL).freeze
  OAI_URL = OaiProcessingToolset.const_get(:OAI_URL).freeze
  ALL_LIB_LOCATIONS = OaiProcessingToolset.const_get(:ALL_LIB_LOCATIONS).freeze
  LIB_LOC_PAIRS = OaiProcessingToolset.const_get(:LIB_LOC_PAIRS).freeze

  attr_reader :document, :xml_type, :logger

  def self.all_rules(document:, xml_type:)
    [
      OaiValidation::DeletedRecordsRule.new(document: document, xml_type: xml_type),
      OaiValidation::SuppressedRecordsRule.new(document: document, xml_type: xml_type),
      OaiValidation::LostStolenRecordsRule.new(document: document, xml_type: xml_type),
      OaiValidation::DeactivatedPortfoliosRule.new(document: document, xml_type: xml_type),
      OaiValidation::TemporaryLocatedRecordsRule.new(document: document, xml_type: xml_type)
    ]
  end

  def initialize(document:, xml_type:)
    @document = document
    @xml_type = xml_type
  end

  # Name of the validation rule
  # @return [String] name of the rule
  def name
    raise "Method #name has not been implemented for this rule"
  end

  # Description of the validation rule
  # @return [String] description of the rule
  def description
    raise "Method #description has not been implemented for this rule"
  end

  # Return array of all records affected by this rule
  # @return [Array<Int>] IDs of records affected
  def record_ids
    raise "Method #record_ids has not been implemented for this rule"
  end

  # Apply requirements of the rule
  # @return [Array<Int>] IDs of records affected
  def apply
    raise "Method #apply has not been implemented for this rule"
  end
end
