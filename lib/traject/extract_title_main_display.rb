# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractTitleMainDisplay
  def extract_title_main_display
    lambda do |rec, acc|
      prefix, middle, suffix, string_array = Array.new(4) { [] }
      fill_section_arrays(rec, prefix, middle, suffix)
      fill_string_array(prefix, middle, suffix, string_array)
      acc << string_array.flatten.join('')
    end
  end

  def fill_string_array(prefix, middle, suffix, string_array)
    fill_str_arr_prefix(string_array, prefix)
    string_array << ": " + middle.flatten.join('. ') unless middle.all?("")
    fill_str_arr_suffix(string_array, suffix)
  end

  def fill_middle(middle, record)
    middle << extract_join_remove(record, '245b')
    middle << extract_join_remove(record, '245n')
  end

  def fill_section_arrays(record, prefix, middle, suffix)
    prefix << extract_join_remove(record, '245a')
    fill_middle(middle, record)
    suffix << extract_join_remove(record, '245p')
  end
end
