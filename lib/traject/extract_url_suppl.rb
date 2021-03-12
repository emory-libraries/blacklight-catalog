# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractUrlSuppl
  def extract_url_suppl
    lambda do |rec, acc|
      rec.fields('856').each do |f|
        case f.indicator2
        when '2'
          accumulate_urls(f, acc)
        when '0'
          # do nothing
        else
          accumulate_field_u(f, acc) if notfulltext.match?(fields_z3(f))
        end
      end
    end
  end
end
