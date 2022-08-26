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
    field.indicator2 == '7' && field.subfields.any? do |subfield|
      subfield.code == '2' && valid_sources.include?(subfield.value)
    end
  end
end
