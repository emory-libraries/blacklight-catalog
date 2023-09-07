# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractGenre
  def extract_genre
    lambda do |record, accumulator|
      tags = ['655a']

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid_genre_field?(field)
          value = marc21.trim_punctuation(extract_value(tag, field))
          accumulator << value unless value.nil? || accumulator.include?(value)
        end
      end
      accumulator
    end
  end

  def valid_genre_field?(field)
    (['0', '2'].include? field.indicator2) || valid_genre_source?(field)
  end

  def valid_genre_source?(field)
    valid_sources = ['lcgft', 'homoit', 'aat', 'rbbin', 'rbgenr', 'rbpap', 'rbpri', 'rbprov', 'rbpub']
    return false unless field.indicator2 == '7'
    source = field.subfields.find { |sf| sf.code == '2' }
    return false if source.blank?

    if valid_sources.include?(source.value)
      true
    else
      source.value == 'local' && field.subfields.find { |sf| sf.code == '5' and sf.value == 'GEU' }.present?
    end
  end
end
