# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractAuthorDisplay
  def extract_author_display
    lambda do |rec, acc|
      authors = extract_fields_strict_subfield_order(rec, '100 abcdgqe:110 abcdgne:111 acdegjnqj')
      authors.each { |a| acc << marc21.trim_punctuation(a) } if authors.present?
    end
  end
end
