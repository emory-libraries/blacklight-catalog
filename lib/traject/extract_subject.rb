# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractSubject
  def extract_subject_tesim
    atoz = ('a'..'z').to_a.join('')
    tags = %W[
      600#{atoz} 610#{atoz} 611#{atoz} 630#{atoz} 650#{atoz}
      651#{atoz} 653#{atoz} 654#{atoz} 655#{atoz} 656#{atoz}
      657#{atoz} 658#{atoz} 662#{atoz} 688#{atoz} 690#{atoz}
      691#{atoz} 692#{atoz} 693#{atoz} 694#{atoz} 695#{atoz}
      696#{atoz} 697#{atoz} 698#{atoz} 699#{atoz}
    ]
    lf = LanguageFilter.new
    language_filter_log_path = Rails.root.join('tmp', 'language_filter.log')
    logger = Logger.new(language_filter_log_path)

    lambda do |record, accumulator|
      record_id = record.find { |f| f.tag == '001' }&.value

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          value = extract_value(tag, field, ' ')
          unless value.nil? || accumulator.include?(value)
            if lf.valid?(value)
              accumulator << value
            else
              replacement = lf.filter(value)
              accumulator << value
              accumulator << replacement
              logger.info "Language filter change for record: ###{record_id}##, field: `subject_tesim`; Append \"#{replacement}\" due to the existence of \"#{value}\""
            end
          end
        end
      end
      accumulator
    end
  end

  def extract_subject_ssim
    lf = LanguageFilter.new
    language_filter_log_path = Rails.root.join('tmp', 'language_filter.log')
    logger = Logger.new(language_filter_log_path)

    lambda do |record, accumulator|
      record_id = record.find { |f| f.tag == '001' }&.value
      tags = ['600abcdq', '610ab', '611adc', '630aa', '650aa', '653aa', '654a']

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid_subject_field?(field)
          value = marc21.trim_punctuation(extract_value(tag, field, ' '))

          unless value.nil? || accumulator.include?(value)
            if lf.valid?(value)
              accumulator << value
            else
              replacement = lf.filter(value)
              accumulator << replacement
              logger.info "Language filter change for record: ###{record_id}##, field: `subject_ssim`; Replace \"#{value}\" with \"#{replacement}\""
            end
          end
        end
      end
      accumulator
    end
  end

  def valid_subject_field?(field)
    (['0', '2'].include? field.indicator2) || valid_subject_source?(field)
  end

  def valid_subject_source?(field)
    valid_sources = ['lcgft', 'homoit', 'aat', 'rbbin', 'rbgenr', 'rbpap', 'rbpri', 'rbprov', 'rbpub']
    field.indicator2 == '7' && field.subfields.any? do |subfield|
      subfield.code == '2' && valid_sources.include?(subfield.value)
    end
  end
end
