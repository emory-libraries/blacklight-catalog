# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractSubjectEra
  def extract_subject_era
    lambda do |record, accumulator|
      tags = ['650y', '651y', '654y', '655y']

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid_subject_era_field?(field)
          value = marc21.trim_punctuation(extract_value(tag, field))
          accumulator << value unless value.nil? || accumulator.include?(value)
        end
      end
      accumulator
    end
  end

  def valid_subject_era_field?(field)
    (['0', '2'].include? field.indicator2) || valid_subject_era_source?(field)
  end

  def valid_subject_era_source?(field)
    valid_sources = ['lcgft', 'homoit', 'aat', 'rbbin', 'rbgenr', 'rbpap', 'rbpri', 'rbprov', 'rbpub']
    field.indicator2 == '7' && field.subfields.any? do |subfield|
      subfield.code == '2' && valid_sources.include?(subfield.value)
    end
  end
end
