# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module Extract3aFields
  def extract_3a_fields(tag)
    lambda do |record, accumulator|
      record.each_by_tag(tag) do |field|
        a_subfield = field['a']

        note = extractor_subfield3(field)
        note += note.empty? ? a_subfield.to_s : " #{a_subfield}" if a_subfield

        accumulator << note.strip unless note.strip.empty?
      end
    end
  end

  def extract_541_subfields_with_colon
    lambda do |record, accumulator|
      record.each_by_tag('541') do |field|
        c_subfield = field['c']
        a_subfield = field['a']

        note = extractor_subfield3(field)
        note += note.empty? ? a_subfield.to_s : " #{a_subfield}" if a_subfield
        note += note.empty? ? c_subfield.to_s : " #{c_subfield}" if c_subfield

        accumulator << note.strip unless note.strip.empty?
      end
    end
  end

  def extract_540_subfields
    lambda do |record, accumulator|
      record.each_by_tag('540') do |field|
        a_subfield = field['a']
        f_subfield = field['f']
        u_subfield = field['u']

        note = extractor_subfield3(field)
        note += note.empty? ? a_subfield.to_s : " #{a_subfield}" if a_subfield
        note += note.empty? ? f_subfield.to_s : " #{f_subfield}" if f_subfield
        note += note.empty? ? u_subfield.to_s : " #{u_subfield}" if u_subfield

        accumulator << note.strip unless note.strip.empty?
      end
    end
  end

  def extract_8xx_with_subfield3(atog)
    lambda do |record, accumulator|
      record.fields(['800', '810', '811']).each do |field|
        note = extractor_subfield3(field)
        subfields_to_extract = title_series_8xx_str(atog).split(':').find { |s| s.start_with?(field.tag) }
        subfields_to_extract = subfields_to_extract[3..-1] if subfields_to_extract
        other_subfields = field.subfields.select { |sf| subfields_to_extract.include?(sf.code) && sf.code != '3' }.map(&:value).join(' ')
        note += note.empty? ? other_subfields : " #{other_subfields}" if other_subfields.present?
        accumulator << note.strip unless note.strip.empty?
      end
    end
  end
end

private

def extractor_subfield3(field)
  subfield3 = field['3']
  subfield3 ? subfield3.chomp(':') + ':' : ''
end
