# frozen_string_literal: true

class OaiValidation::TemporaryLocatedRecordsRule < OaiValidation::Rule
  def name
    "Temporarily Located"
  end

  def description
    "Remove all records that were temporarily located."
  end

  def record_ids
    temporarily_located_records = pull_temp_location_records(document)
    pull_ids_from_category_array(temporarily_located_records)
  end

  def apply
    temporarily_located_records = pull_temp_location_records(document)
    temporarily_located_record_ids = pull_ids_from_category_array(temporarily_located_records)
    temporarily_located_records.each(&:remove)
    temporarily_located_record_ids
  end
end
