# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractTitleMainFirstChar
  def extract_title_main_first_char
    lambda do |rec, acc|
      title = Traject::Macros::Marc21Semantics.get_sortable_title(rec)
      acc << title.match(/(\w|\p{L})/)[0].upcase if title.present?
    end
  end
end
