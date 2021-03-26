# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractSubjectDisplay
  def extract_subject_display(atoz, atog, vtoz)
    lambda do |rec, acc|
      dfs_to_process = [
        "600#{atoz}", "610#{atoz}", "611#{atoz}", "630#{atoz}", "650#{atog}#{vtoz}",
        "651aeg#{vtoz}"
      ]

      dfs_to_process.each do |df|
        rec.fields(df.to_i.to_s).find_all do |f|
          acc << accumulate_values(df, f) unless f.indicator2 == "4" || any_subfield_fast?(f)
        end
      end
      acc
    end
  end

  def any_subfield_fast?(field)
    field.subfields.any? { |sf| sf.code == '2' && sf.value == "fast" }
  end

  def accumulate_values(df, field)
    ret_array = []
    field.each do |sf|
      ret_array << sf.value if df.delete(df.to_i.to_s + "vxyz").include?(sf.code)
      ret_array << "--#{sf.value}" if "vxyz".include?(sf.code)
    end
    ret_array.join('')
  end
end
