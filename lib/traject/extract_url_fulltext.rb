# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractUrlFulltext
  def extract_url_fulltext
    lambda do |rec, acc|
      rec.fields('856').each do |f|
        case f.indicator2
        when '0', '1'
          base_url = f.find { |field| field.code == 'u' }&.value
          next unless base_url

          url = parse_url(base_url)
          exclude_links_to = ["table of contents", "table of contents only", "publisher description", "cover image", "contributor biographical information", "sample text"]
          label = [f['y'], f['3'], f['z']].compact.first
          next if label.present? && exclude_links_to.include?(label.downcase)

          acc << { url:, label: }.to_json if url.present?
        when '2'
          # do nothing
        else
          accumulate_field_u(f, acc) unless notfulltext.match?(fields_z3(f))
        end
      end
    end
  end
end
