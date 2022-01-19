# frozen_string_literal: true

class OaiValidation::TemporaryLocatedRecordsRule < OaiValidation::Rule
  def name
    "Temporarily Located"
  end

  def description
    "Remove all records that were temporarily located."
  end

  def record_ids
    temporarily_located_records = pull_temp_location_records
    temporarily_located_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
  end

  def apply
    temporarily_located_records = pull_temp_location_records
    temporarily_located_record_ids = temporarily_located_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
    temporarily_located_records.each(&:remove)
    temporarily_located_record_ids
  end

  private

  def pull_temp_location_records
    document.xpath('//marc:record', MARC_URL).select do |d|
      nine_nine_sevens = d.xpath("marc:datafield[@tag='997']", MARC_URL)
      temporaries = nine_nine_sevens.select do |i|
        library = i.xpath("marc:subfield[@code='c']", MARC_URL).text
        location = i.xpath("marc:subfield[@code='d']", MARC_URL).text

        ALL_LIB_LOCATIONS.include?(location&.upcase) || LIB_LOC_PAIRS.include?([library&.upcase, location&.upcase])
      end
      temporaries.size.positive? && nine_nine_sevens.size == temporaries.size
    end
  end
end
