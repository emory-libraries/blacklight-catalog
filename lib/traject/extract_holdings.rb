# frozen_string_literal: true

module ExtractHoldings
  def extract_holdings
    lambda do |rec, acc|
      rec.fields('HOL852').each do |f|
        build_holding_hash(f, acc)
      end
    end
  end

  def build_holding_hash(field, accumulator)
    holding_id = field['8']
    library_code = field['b']
    location_code = field['c']
    call_number_start = field['h']
    call_number_cutter = field['i']
    call_number = call_number_start.to_s + call_number_cutter.to_s if call_number_start
    accumulator << {
      holding_id: holding_id,
      library_code: library_code,
      location_code: location_code,
      call_number: call_number
    }.to_json
  end
end
