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

    accumulator << {
      holding_id: holding_id,
      library: library(field),
      location: location(field),
      call_number: call_number(field)
    }.to_json
  end

  def library(field)
    map = Traject::TranslationMap.new('libraryname_map')
    library_code = field['b']
    library_label = map[library_code]
    { label: library_label,
      value: library_code }
  end

  def location(field)
    location_code = field['c']
    {
      label: "Ur, I dunno",
      value: location_code
    }
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
