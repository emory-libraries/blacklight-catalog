# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractUrlSuppl
  def extract_url_suppl
    lambda do |rec, acc|
      url_fields = rec.fields('856').select { |f| ['0', '1', '2'].include?(f.indicator2) || f.indicator2.blank? }
      url_fields.each do |uf|
        next if uf['u'].blank?
        build_str = uf['u']
        pulled_text = [uf['y'], uf['3'], uf['z']].compact.first

        if ['0', '1'].include?(uf.indicator2)
          include_links_to = ["table of contents", "table of contents only", "publisher description", "cover image", "contributor biographical information"]
          next if pulled_text.nil? || include_links_to.exclude?(pulled_text.downcase)
        end

        build_str += " text: #{marc21.trim_punctuation(pulled_text)}" if pulled_text.present?
        acc << build_str
      end
    end
  end
end
