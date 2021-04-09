# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractAuthorAddlDisplay
  def extract_author_addl_display
    lambda do |rec, acc|
      ret_values = []

      ['700 abcdgqte', '710 abcdgne', '711 acdegnqej'].each do |v|
        field_num = v.to_i.to_s
        text_fields = v.split(' ').last.split('')[0...-1]
        relator_field = v.split(' ').last.split('').last
        build_ret_strings(rec, field_num, text_fields, relator_field, ret_values)
      end

      ret_values.flatten.compact.uniq.each { |v| acc << v }
    end
  end

  def build_ret_strings(record, field_num, text_fields, relator_field, ret_values)
    record.fields(field_num).each do |f|
      build_str = gather_author_string(f, text_fields)
      relator_string = gather_relator_string(f, relator_field)
      build_str += " relator: #{relator_string}" if relator_string.present?
      ret_values << build_str
    end
  end

  def gather_relator_string(field, relator_field)
    build_arr = []
    field.subfields.each { |sf| build_arr << marc21.trim_punctuation(sf.value) if relator_field == sf.code }
    ret_str = case build_arr.size
              when 0
                ''
              when 1
                build_arr[0]
              when 2
                "#{build_arr[0]} and #{build_arr[1]}"
              else
                build_arr[0...-1].join(', ') + ", and #{build_arr.last}"
              end
    ret_str
  end

  def gather_author_string(field, text_fields)
    build_arr = []
    field.subfields.each { |sf| build_arr << sf.value if text_fields.any? { |tf| tf == sf.code } }
    marc21.trim_punctuation(build_arr.join(' '))
  end
end
