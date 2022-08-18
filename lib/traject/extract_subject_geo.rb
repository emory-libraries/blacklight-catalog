# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractSubjectGeo
  def extract_subject_geo
    lambda do |record, accumulator|
      tags = ['651a', '650z']

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid?(field)
          value = marc21.trim_punctuation(accumulate_values(tag, field))
          accumulator << value unless accumulator.include?(value)
        end
      end
      accumulator
    end
  end

  def valid?(field)
    (['0', '2'].include? field.indicator2) || valid_source?(field)
  end

  def valid_source?(field)
    valid_sources = ['lcgft', 'homoit', 'aat', 'rbbin', 'rbgenr', 'rbpap', 'rbpri', 'rbprov', 'rbpub']
    field.indicator2 == '7' && field.subfields.any? do |subfield|
      subfield.code == '2' && valid_sources.include?(subfield.value)
    end
  end

  def accumulate_values(tag, field)
    valid_subfield_codes = tag.delete(tag.to_i.to_s)
    subfield_values = {}
    field.subfields.each do |subfield|
      next unless valid_subfield_codes.include? subfield.code

      if subfield_values[subfield.code].present?
        subfield_values[subfield.code] << subfield.value
      else
        subfield_values[subfield.code] = [subfield.value]
      end
    end
    field_value = []
    valid_subfield_codes.split('').each { |key| field_value.concat subfield_values[key].to_a }
    field_value.join(' ')
  end
end
