# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractUrlFulltext
  def extract_url_fulltext
    lambda do |rec, acc|
      rec.fields('856').each do |f|
        case f.indicator2
        when '0', '1'
          accumulate_urls(f, acc)
        when '2'
          # do nothing
        else
          accumulate_field_u(f, acc) unless notfulltext.match?(fields_z3(f))
        end
      end
    end
  end
end
