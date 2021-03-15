# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractPublisherDetailsDisplay
  def extract_publisher_details_display
    lambda do |rec, acc|
      extra_fields = []
      ['260b', '264b', '260a', '264a'].each do |f|
        extra_fields << extract_join_remove(rec, f)
      end
      extra_fields << marc21.extract_marc_from(rec, '008[15-17]')
      acc << extra_fields.flatten.join(' ')
    end
  end
end
