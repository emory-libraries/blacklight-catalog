# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module Extract3aFields
  def extract_3a_fields(tag)
    lambda do |record, accumulator|
      record.each_by_tag(tag) do |field|
        three_subfield = field['3']
        a_subfield = field['a']

        next unless three_subfield
        three_subfield += ':' unless three_subfield.end_with?(':')
        note = three_subfield
        note += " #{a_subfield}" if a_subfield
        accumulator << note
      end
    end
  end

  def extract_541_subfields_with_colon
    lambda do |record, accumulator|
      record.each_by_tag('541') do |field|
        three_subfield = field['3']
        c_subfield = field['c']
        a_subfield = field['a']

        next unless three_subfield

        three_subfield += ':' unless three_subfield.end_with?(':')

        note = three_subfield
        note += " #{c_subfield}" if c_subfield
        note += " #{a_subfield}" if a_subfield

        accumulator << note
      end
    end
  end

  def extract_540_subfields
    lambda do |record, accumulator|
      record.each_by_tag('540') do |field|
        three_subfield = field['3']
        a_subfield = field['a']
        f_subfield = field['f']
        u_subfield = field['u']

        next unless three_subfield
        three_subfield += ':' unless three_subfield.end_with?(':')
        note = [three_subfield, a_subfield, f_subfield, u_subfield].compact.join(' ')
        accumulator << note
      end
    end
  end

  def extract_7xx_8xx_with_subfield3(tag)
    lambda do |record, accumulator|
      record.each_by_tag(tag) do |field|
        three_subfield = field['3']
        next unless three_subfield

        three_subfield += ':' unless three_subfield.end_with?(':')

        rest_of_field = field.map { |sf| sf.value.to_s unless sf.code == '3' }.compact.join(' ')
        note = "#{three_subfield} #{rest_of_field}"

        accumulator << note
      end
    end
  end

  def extract_8xx_with_subfield3(atog)
    lambda do |record, accumulator|
      record.fields(['800', '810', '811']).each do |field|
        subfield3 = field['3']

        subfield3 += ':' if subfield3 && !subfield3.end_with?(':')
        subfields_to_extract = title_series_8xx_str(atog).split(':').find { |s| s.start_with?(field.tag) }
        other_subfields = field.subfields.select { |sf| subfields_to_extract.include?(sf.code) }
                               .map(&:value)
                               .join(' ')

        full_string = subfield3 ? "#{subfield3} #{other_subfields}".strip : other_subfields.strip
        accumulator << full_string unless full_string.empty?
      end
    end
  end
end
