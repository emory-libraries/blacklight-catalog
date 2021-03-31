# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractFindingAidUrl
  def extract_finding_aid_url
    lambda do |rec, acc|
      url_fields = rec.fields('555').select { |f| f.indicator1 == '0' }
      url_fields.each do |uf|
        next if uf['u'].blank?
        build_str = uf['u']
        pulled_text = uf['a']
        build_str += " text: #{marc21.trim_punctuation(pulled_text)}" if pulled_text.present?
        acc << build_str
      end
    end
  end
end
