# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractBarcode
  def extract_barcode
    lambda do |record, accumulator|
      barcodes = ['997a']

      barcodes.each do |barcode|
        record.fields(barcode.to_i.to_s).find_all do |field|
          value = marc21.trim_punctuation(extract_value(barcode, field))
          accumulator << value unless value.nil? || accumulator.include?(value)
        end
      end
      accumulator
    end
  end
end
