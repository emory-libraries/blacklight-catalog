# frozen_string_literal: true

module ExtractOtherStandardIds
  def extract_other_standard_ids
    lambda do |rec, acc|
      rec.fields('024').each do |f|
        prefix = map_prefix(f)
        suffix = f['a']
        string_array = []
        string_array << "#{prefix}: " unless prefix.to_s.strip.empty?
        string_array << suffix.to_s unless suffix.to_s.strip.empty?
        acc << string_array.flatten.join('')
      end
    end
  end

  def map_prefix(field)
    prefixes = { "0" => "International Standard Recording Code", "1" => "Universal Product Code",
                 "2" => "International Standard Music Number", "3" => "International Article Number",
                 "4" => "Serial Item and Contribution Identifier", "7" => field['2'],
                 "8" => "Unspecified" }
    prefixes[field.indicator1]
  end
end
