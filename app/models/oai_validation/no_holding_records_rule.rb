# frozen_string_literal: true

class OaiValidation::NoHoldingRecordsRule < OaiValidation::Rule
  def name
    "Records With No Physical Or Electronic Holdings"
  end

  def description
    "Remove all records containing no electronic or physical holdings."
  end

  def record_ids
    no_holdings_records = pull_no_holdings_records
    no_holdings_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
  end

  def apply
    no_holdings_records = pull_no_holdings_records
    no_holdings_records_ids = no_holdings_records.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
    no_holdings_records.each(&:remove)
    no_holdings_records_ids
  end

  private

  def pull_no_holdings_records
    document.xpath('//marc:record', MARC_URL).select do |d|
      get_998_count(d).zero? && !document_contain_physical?(d)
    end
  end
end
