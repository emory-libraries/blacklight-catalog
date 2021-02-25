# frozen_string_literal: true

module ExtractCollection
  def extract_collection
    lambda do |rec, acc|
      ret_values = []

      needed_subf_values(rec).each { |v| ret_values << v } unless needed_subf_values(rec).empty?
      pulled_490a_values(rec).each { |v| ret_values << v } if ret_values.empty?
      ret_values.each { |v| acc << v }
    end
  end

  def marc21
    Traject::Macros::Marc21
  end

  def corp_name_datafields(record)
    record.fields('710').select do |f|
      f.indicator1 == '2' && f.subfields.any? { |s| s.value == 'GEU' }
    end
  end

  def c_n_subfield_values(datafields)
    datafields&.map { |df| df.subfields.map { |sf| sf.value if sf.code == 'a' } }&.compact&.flatten
  end

  def pulled_490a_values(record)
    marc21.extract_marc_from(record, '490a')
  end

  def needed_subf_values(record)
    c_n_subfield_values(corp_name_datafields(record))
  end
end
