# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractCollection
  def extract_collection
    lambda do |rec, acc|
      ret_values = []

      needed_subf_values(rec).each { |v| ret_values << v } unless needed_subf_values(rec).empty?
      pulled_490a_values(rec).each { |v| ret_values << v } if ret_values.empty?
      ret_values.each { |v| acc << v }
    end
  end

  def pulled_490a_values(record)
    marc21.extract_marc_from(record, '490a')
  end

  def needed_subf_values(record)
    c_n_subfield_values(corp_name_datafields(record))
  end
end
