# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractUrlSuppl
  def extract_url_suppl
    lambda do |rec, acc|
      url_fields = rec.fields('856').select { |f| f.indicator2 == '2' }
      url_fields.each do |uf|
        next if uf['u'].blank?
        build_str = uf['u']
        pulled_text = [uf['y'], uf['3'], uf['z']].compact
        build_str += " text: #{marc21.trim_punctuation(pulled_text.first)}" if pulled_text.present?
        acc << build_str
      end
    end
  end
end
