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
      build_str = marc21.trim_punctuation(
        text_fields.map do |t|
          f.subfields.map { |sf| sf.value if sf.code == t }.compact.flatten
        end.compact.flatten.join(' ')
      )
      build_str += " relator: #{f[relator_field]}" if f[relator_field].present?
      ret_values << build_str
    end
  end
end
