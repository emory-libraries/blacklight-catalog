# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractSubjectEra
  def extract_subject_era
    lambda do |record, accumulator|
      tags = ['650y', '651y', '654y', '655y']

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid?(field)
          value = marc21.trim_punctuation(subject_era_value(tag, field))
          accumulator << value unless value.nil? || accumulator.include?(value)
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

  def subject_era_value(tag, field)
    valid_subfield_codes = tag.delete(tag.to_i.to_s)
    field_values = []
    field.subfields.each do |subfield|
      next unless valid_subfield_codes.include? subfield.code

      field_values.append(subfield.value)
    end
    field_values.empty? ? nil : field_values.join('')
  end
end
