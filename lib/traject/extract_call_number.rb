# frozen_string_literal: true

module ExtractCallNumber
  def extract_call_number
    lambda do |rec, acc|
      rec.fields('HOL852').each do |field|
        ret_array = collect_subfields(field)
        ret_array.each { |r| acc << field[r] }
      end
    end
  end

  private

  def collect_subfields(field)
    subfields_map = { '0' => ["h", "i"], '1' => ["h"], '2' => ["h"], '3' => ["h", "i"], '4' => ["c", "j"],
                      '8' => ["b", "c", "j"] }
    subfields_map[field.indicator1]
  end
end
