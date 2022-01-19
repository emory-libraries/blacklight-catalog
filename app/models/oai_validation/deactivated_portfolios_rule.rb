# frozen_string_literal: true

class OaiValidation::DeactivatedPortfoliosRule < OaiValidation::Rule
  def description
    "Remove all records listed under deactivated portfolios."
  end

  def record_ids
    deactivated_portfolios = pull_deactivated_portfolios(document)
    pull_ids_from_category_array(deactivated_portfolios, 'Deactivated Portfolio', [])
  end

  def apply
    deactivated_portfolios = pull_deactivated_portfolios(document)
    deactivated_portfolios_ids = pull_ids_from_category_array(deactivated_portfolios, 'Deactivated Portfolio', [])
    deactivated_portfolios.each(&:remove)
    deactivated_portfolios_ids
  end
end
