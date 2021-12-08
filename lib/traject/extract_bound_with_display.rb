# frozen_string_literal: true
module ExtractBoundWithDisplay
  FALLBACK_PHRASE = 'This material may be contained within another physical item. Please check the parent record for details.'

  def extract_bound_with_display
    lambda do |rec, acc|
      rec.fields('773').each do |f|
        temp_id = f['w']&.strip
        next unless temp_id&.first(2) == '99' && temp_id&.last(4) == '2486'
        bound_with_text = f['t'] || FALLBACK_PHRASE

        acc << { mms_id: temp_id, text: bound_with_text }.to_json
      end
    end
  end
end
