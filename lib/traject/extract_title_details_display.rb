# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractTitleDetailsDisplay
  def extract_title_details_display
    lambda do |rec, acc|
      prefix, suffix, string_array = Array.new(3) { [] }
      prefix << extract_join_remove(rec, '245a')
      fill_suffix(suffix, rec)
      fill_str_arr_total(string_array, prefix, suffix)
      acc << string_array.flatten.join('')
    end
  end

  def fill_str_arr_total(string_array, prefix, suffix)
    fill_str_arr_prefix(string_array, prefix)
    string_array << ": " + suffix.flatten.join('. ') unless suffix.all?("")
  end

  def fill_suffix(suffix, record)
    suffix << extract_join_remove(record, '245b')
    suffix << extract_join_remove(record, '245p')
  end
end
