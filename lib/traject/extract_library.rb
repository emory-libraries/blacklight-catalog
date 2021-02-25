# frozen_string_literal: true

module ExtractLibrary
  def extract_library
    lambda do |rec, acc|
      subfields = rec.fields("HOL852").map(&:subfields).flatten
      ret_values = subfields.map { |s| s.value if s.code == 'b' }.compact
      ret_values.each { |v| acc << v }
    end
  end
end
