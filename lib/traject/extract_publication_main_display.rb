# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractPublicationMainDisplay
  def extract_publication_main_display
    lambda do |rec, acc|
      prefix, suffix, string_array = Array.new(3) { [] }
      fill_prefix(prefix, rec)
      fill_pub_suffix(suffix, rec)
      populate_string_array(prefix, suffix, string_array)
      acc << string_array.flatten.join('')
    end
  end

  def fill_prefix(prefix, record)
    ['260a', '264a'].each { |f| prefix << extract_join_remove(record, f) }
    prefix << marc21.extract_marc_from(record, '008[15-17]')
  end

  def fill_pub_suffix(suffix, record)
    ['260b', '264b', '260c', '264c'].each { |f| suffix << extract_join_remove(record, f) }
    suffix << marc21.extract_marc_from(record, '008[7-10]')
  end

  def populate_string_array(prefix, suffix, string_array)
    fill_str_arr_prefix(string_array, prefix)
    fill_str_arr_suffix(string_array, suffix)
  end
end
