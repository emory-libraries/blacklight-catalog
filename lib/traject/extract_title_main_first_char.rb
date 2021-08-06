# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractTitleMainFirstChar
  def extract_title_main_first_char
    lambda do |rec, acc|
      titles = marc21.extract_marc_from(rec, '245abfgknps', alternate_script: false)
      titles.each { |t| acc << t.match(/(\w|\p{L})/)[0].upcase } if titles.present?
    end
  end
end
