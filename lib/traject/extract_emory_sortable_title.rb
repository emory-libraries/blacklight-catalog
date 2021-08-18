# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractEmorySortableTitle
  def extract_emory_sortable_title
    lambda do |record, accumulator|
      st = marc_semantics.get_sortable_title(record)
      accumulator << remove_punct_from_string(st) if st
    end
  end
end
