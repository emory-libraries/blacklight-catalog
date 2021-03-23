# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractEmoryCollection
  def extract_emory_collection
    lambda do |rec, acc|
      c_n_subfield_values(corp_name_datafields(rec)).each { |v| acc << v }
    end
  end
end
