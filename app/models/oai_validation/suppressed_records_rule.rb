# frozen_string_literal: true

class OaiValidation::SuppressedRecordsRule < OaiValidation::Rule
  def description
    "Remove all records that were suppressed."
  end

  def record_ids
    suppressed_records = document.xpath("//marc:record[substring(marc:leader, 6, 1)='d']", MARC_URL) # gets all records with `d` in the 6th (actual) position of leader string
    pull_ids_from_category_array(suppressed_records, 'Suppressed', [])
  end

  def apply
    suppressed_records = document.xpath("//marc:record[substring(marc:leader, 6, 1)='d']", MARC_URL) # gets all records with `d` in the 6th (actual) position of leader string
    suppressed_record_ids = pull_ids_from_category_array(suppressed_records, 'Suppressed', [])
    suppressed_records.remove
    suppressed_record_ids
  end
end
