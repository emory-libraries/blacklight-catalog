# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractFormatString
  def extract_format_string
    lambda do |rec, acc|
      acc << format_map_ldr_six[rec.leader[6].to_s] if format_map_ldr_six.keys.any?(rec.leader[6])
      acc << format_map_ldr_six_seven[rec.leader[6, 2].to_s] if format_map_ldr_six_seven.keys.any?(rec.leader[6, 2])
    end
  end
end
