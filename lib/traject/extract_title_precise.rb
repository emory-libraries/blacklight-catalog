# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractTitlePrecise
  def extract_title_precise
    lambda do |rec, acc|
      title = marc_semantics.get_sortable_title(rec)
      acc << title if title.present?
    end
  end
end
