# frozen_string_literal: true

class Verification::TheoUserVerificationService < Verification::IlliadVerificationService
  THEO_COMMON = %w[01 02 03 09 10 20 23].freeze
  THEO_COMMON_2 = %w[02 03 10].freeze
  THEO_COMMON_3 = %w[01 02 03 04 23 24 25].freeze

  def document_delivery?
    book_analyses(@document_holding) ||
      analyze_values(THEO_COMMON, "PER", BOOK_ISSBD, @document_holding) ||
      analyze_values(THEO_COMMON_2, "STACK", %w[BOOK CDROM], @document_holding) ||
      analyze_values(THEO_COMMON_2, "STOR", BOOK_ISS_MLTVL, @document_holding) ||
      analyze_values(%w[02 03 04 10 24 25], "STOR", BOOK_ISS, @document_holding)
  end

  def book_analyses(holding)
    analyze_values_from_location_array(%w[CIRC CPER ONFLY], THEO_COMMON, %w[BOOK], holding) ||
      analyze_values_from_location_array(%w[REF RFDESK REFOV], THEO_COMMON_3, %w[BOOK], holding) ||
      analyze_values_from_location_array(%w[OSIZE PEROZ], THEO_COMMON_2, %w[BOOK], holding) ||
      analyze_values(%w[01 03 04 09 20 23 25], "STACK", %w[BOOK], holding)
  end
end
