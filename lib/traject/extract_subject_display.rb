# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractSubjectDisplay
  def extract_subject_display
    atoz = ('a'..'z').to_a.join('')
    atog = ('a'..'g').to_a.join('')
    vtoz = ('v'..'z').to_a.join('')

    lf = LanguageFilter.new
    language_filter_log_path = Rails.root.join('tmp', 'language_filter.log')
    logger = Logger.new(language_filter_log_path)

    lambda do |record, accumulator|
      record_id = record.find { |f| f.tag == '001' }&.value
      tags = ["600#{atoz}", "610#{atoz}", "611#{atoz}", "630#{atoz}", "650#{atog}#{vtoz}", "651aeg#{vtoz}"]

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid_subject_display_field?(field)
          value = marc21.trim_punctuation(subject_display_value(tag, field))
          unless value.nil? || accumulator.include?(value)
            if lf.valid?(value)
              accumulator << value
            else
              replacement = lf.filter(value)
              accumulator << replacement
              logger.info "Language filter change for record: ###{record_id}##, field: `subject_display_ssim`; Replace \"#{value}\" with \"#{replacement}\""
            end
          end
        end
      end
      accumulator
    end
  end

  def valid_subject_display_field?(field)
    ((['0', '2'].include? field.indicator2) || valid_subject_display_source?(field)) && !(field.subfields.any? { |sf| sf.code == '2' && sf.value == "fast" })
  end

  def valid_subject_display_source?(field)
    valid_sources = ['lcgft', 'homoit', 'aat', 'rbbin', 'rbgenr', 'rbpap', 'rbpri', 'rbprov', 'rbpub']
    field.indicator2 == '7' && field.subfields.any? do |subfield|
      subfield.code == '2' && valid_sources.include?(subfield.value)
    end
  end

  def subject_display_value(tag, field)
    valid_subfield_codes = tag.delete(tag.to_i.to_s)
    field_values = []
    field.subfields.each do |subfield|
      next unless valid_subfield_codes.include? subfield.code

      value = 'vxyz'.include?(subfield.code) ? "--#{subfield.value}" : subfield.value
      field_values.append(value)
    end
    field_values.empty? ? nil : field_values.join('')
  end
end
