# frozen_string_literal: true
require 'traject/extraction_tools'
extend ExtractionTools

module ExtractSubjectDisplay
  def extract_subject_display(atoz, atog, vtoz)
    lambda do |rec, acc|
      ret_array = []
      dfs_to_process = [
        "600#{atoz}", "610#{atoz}", "611#{atoz}", "630#{atoz}", "650#{atog}#{vtoz}",
        "651aeg#{vtoz}"
      ]

      eliminate_datafields(dfs_to_process, rec)
      dfs_to_process.each { |df| ret_array << marc21.extract_marc_from(rec, df) }
      ret_array.compact.flatten.each { |v| acc << v }
    end
  end

  def rules_for_exclusion?(record, field_number)
    record.fields(field_number).any? { |f| f.indicator2 == "4" || any_subfield_fast?(f) }
  end

  def any_subfield_fast?(field)
    field.subfields.any? { |sf| sf.code == '2' && sf.value == "fast" }
  end

  def eliminate_datafields(dfs_to_process, record)
    dfs_to_process.each do |df|
      field_number = df.to_i.to_s

      dfs_to_process.delete(df) if rules_for_exclusion?(record, field_number)
    end
  end
end
