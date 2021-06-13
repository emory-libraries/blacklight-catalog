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
    accumulator << {
      holding_id: holding_id,
      library_code: library_code,
      location_code: location_code,
      call_number: call_number(field)
    }.to_json
  end

  def call_number(field)
    lc_start = field['h']
    lc_cutter = field['i']
    shelving_control_num = field['j']
    if lc_start
      lc_start.to_s + lc_cutter.to_s
    elsif shelving_control_num
      shelving_control_num
    end
  end
end
