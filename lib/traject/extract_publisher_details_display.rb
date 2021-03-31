# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractPublisherDetailsDisplay
  def extract_publisher_details_display
    lambda do |rec, acc|
      extra_fields = []
      ['260b', '264b', '260a', '264a'].each do |f|
        extra_fields << marc21.extract_marc_from(rec, f)
      end
      extra_fields << marc21.extract_marc_from(rec, '008[15-17]')
      acc << extra_fields.compact.flatten.join(' ')
    end
  end
end
