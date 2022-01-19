# frozen_string_literal: true

class OaiValidation::DeletedRecordsRule < OaiValidation::Rule
  def name
    "Deleted"
  end

  def description
    "Remove all records that were deleted."
  end

  def record_ids
    deleted_records = document.xpath("/oai:OAI-PMH/oai:#{xml_type}/oai:record[oai:header/@status='deleted']", OAI_URL)
    pull_deleted_ids(deleted_records)
  end

  def apply
    deleted_records = document.xpath("/oai:OAI-PMH/oai:#{xml_type}/oai:record[oai:header/@status='deleted']", OAI_URL)
    deleted_ids = pull_deleted_ids(deleted_records)
    deleted_records.remove
    deleted_ids
  end
end
