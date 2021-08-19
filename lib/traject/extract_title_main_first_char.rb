# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractTitleMainFirstChar
  def extract_title_main_first_char
    lambda do |rec, acc|
      title = marc_semantics.get_sortable_title(rec)
      matched_chars = title&.match(/(\w|\p{L})/)
      acc << matched_chars[0].upcase if matched_chars.present?
    end
  end
end
