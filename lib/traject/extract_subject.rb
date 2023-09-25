# frozen_string_literal: true

# Fields:
# - 'subject_tesim'
# - 'subject_ssim'
# - 'subject_geo_ssim'
# - 'subject_era_ssim'
# - 'subject_display_ssim'

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

  def extract_subject_geo
    lambda do |record, accumulator|
      tags = ['651a', '650z']

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid_subject_field?(field)
          value = marc21.trim_punctuation(extract_value(tag, field))
          accumulator << value unless value.nil? || accumulator.include?(value)
        end
      end
      accumulator
    end
  end

  def extract_subject_era
    lambda do |record, accumulator|
      tags = ['650y', '651y', '654y', '655y']

      tags.each do |tag|
        record.fields(tag.to_i.to_s).find_all do |field|
          next unless valid_subject_field?(field)
          value = marc21.trim_punctuation(extract_value(tag, field))
          accumulator << value unless value.nil? || accumulator.include?(value)
        end
      end
      accumulator
    end
  end

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

  private

  def valid_subject_field?(field)
    (['0', '2'].include? field.indicator2) || valid_subject_source?(field)
  end

  def valid_subject_display_field?(field)
    ((['0', '2'].include? field.indicator2) || valid_subject_source?(field)) && !(field.subfields.any? { |sf| sf.code == '2' && sf.value == "fast" })
  end

  def valid_subject_source?(field)
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
