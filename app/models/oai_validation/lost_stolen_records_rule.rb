# frozen_string_literal: true

class OaiValidation::LostStolenRecordsRule < OaiValidation::Rule
  def name
    "Lost/Stolen"
  end

  def description
    "Remove all records that were lost or stolen."
  end

  def record_ids
    lost_stolen_records = pull_lost_stolen_records
    lost_stolen_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
  end

  def apply
    lost_stolen_records = pull_lost_stolen_records
    lost_stolen_ids = lost_stolen_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
    lost_stolen_records.each(&:remove)
    lost_stolen_ids
  end

  private

  def pull_lost_stolen_records
    document.xpath('//marc:record', MARC_URL).select do |d|
      hol852_count = d.xpath("marc:datafield[@tag='HOL852']", MARC_URL).size
      holsp_count = d.xpath(
        "marc:datafield[@tag='HOLSP']//marc:subfield[@code='a'][text()='true']", MARC_URL
      ).size
      hol852_count.positive? && hol852_count <= holsp_count
    end
  end
end
