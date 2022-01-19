# frozen_string_literal: true

class OaiValidation::DeactivatedPortfoliosRule < OaiValidation::Rule
  def name
    "Deactivated Portfolios"
  end

  def description
    "Remove all records listed under deactivated portfolios."
  end

  def record_ids
    deactivated_portfolios = pull_deactivated_portfolios
    deactivated_portfolios.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
  end

  def apply
    deactivated_portfolios = pull_deactivated_portfolios
    deactivated_portfolios_ids = deactivated_portfolios.map { |e| e.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
    deactivated_portfolios.each(&:remove)
    deactivated_portfolios_ids
  end

  private

  def pull_deactivated_portfolios
    document.xpath('//marc:record', MARC_URL).select do |d|
      nine_nine_eight_count = get_998_count(d)
      eight_five_sixes = d.xpath("marc:datafield[@tag='856']", MARC_URL).present?
      physical = document_contain_physical?(d)
      deactivate_portfolios_count = get_deact_port_count(d)

      !physical && deactivate_portfolios_count.positive? && !eight_five_sixes && nine_nine_eight_count == deactivate_portfolios_count
    end
  end
end
