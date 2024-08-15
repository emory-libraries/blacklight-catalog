# frozen_string_literal: true
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
end
