# frozen_string_literal: true

class OaiValidation::LostStolenRecordsRule < OaiValidation::Rule
  def name
    "Lost/Stolen"
  end

  def description
    "Remove all records that were lost or stolen."
  end

  def record_ids
    lost_stolen_records = pull_lost_stolen_records(document)
    pull_ids_from_category_array(lost_stolen_records)
  end

  def apply
    lost_stolen_records = pull_lost_stolen_records(document)
    lost_stolen_ids = pull_ids_from_category_array(lost_stolen_records)
    lost_stolen_records.each(&:remove)
    lost_stolen_ids
  end
end
