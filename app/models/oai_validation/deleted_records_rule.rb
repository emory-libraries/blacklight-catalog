# frozen_string_literal: true

class OaiValidation::DeletedRecordsRule < OaiValidation::Rule
  def name
    "Deleted"
  end

  def description
    "Remove all records that were deleted."
  end

  def record_ids
    validated_deleted_records
  end

  def apply
    validated_deleted_records(apply: true)
  end

  private

  def validated_deleted_records(apply: false)
    ret_arr = []
    raw_deleted_records = document.xpath("/oai:OAI-PMH/oai:#{xml_type}/oai:record[oai:header/@status='deleted']", OAI_URL)

    raw_deleted_records.each { |rdr| deleted_record_validating(ret_arr, rdr, apply) }
    ret_arr
  end

  def deleted_record_validating(ret_arr, raw_deleted_record, apply)
    deleted_id = raw_deleted_record.at('header/identifier').text.split(':').last

    if xml_type == 'GetRecord'
      ret_arr << deleted_id
      raw_deleted_record.remove if apply
    else
      qs = "?verb=GetRecord&identifier=oai:alma.#{ENV['INSTITUTION']}:#{deleted_id}&metadataPrefix=marc21"
      get_record_xml = call_oai_for_xml(ENV['ALMA'], ENV['INSTITUTION'], qs, Logger.new(STDOUT))
      parsed_document = Nokogiri::XML(get_record_xml.body)
      get_record_status = parsed_document.at('header/@status').value
      if get_record_status == 'deleted'
        ret_arr << deleted_id
        raw_deleted_record.remove if apply
      end
    end
  end
end
