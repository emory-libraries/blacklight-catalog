# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractUrlFulltextLinktext
  def extract_url_fulltext_linktext
    lambda do |rec, acc|
      rec.fields('856').each do |f|
        accumulate_linktext(f, acc) if f.indicator2 == '0'
      end
    end
  end
end
