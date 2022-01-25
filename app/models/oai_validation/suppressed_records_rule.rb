# frozen_string_literal: true

class OaiValidation::SuppressedRecordsRule < OaiValidation::Rule
  def name
    "Suppressed"
  end

  def description
    "Remove all records that were suppressed."
  end

  def record_ids
    suppressed_records = document.xpath("//marc:record[substring(marc:leader, 6, 1)='d']", MARC_URL) # gets all records with `d` in the 6th (actual) position of leader string
    suppressed_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
  end

  def apply
    suppressed_records = document.xpath("//marc:record[substring(marc:leader, 6, 1)='d']", MARC_URL) # gets all records with `d` in the 6th (actual) position of leader string
    suppressed_record_ids = suppressed_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
    suppressed_records.remove
    suppressed_record_ids
  end
end
