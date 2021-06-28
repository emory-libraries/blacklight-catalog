# frozen_string_literal: true

class Verification::HlthUserVerificationService < Verification::IlliadVerificationService
  COMMON_HEALTH_IDS = %w[01 09 20 23].freeze

  def document_delivery?
    book_iss_analyses(@document_holding) ||
      analyze_values(%w[02 03 04 25], "CIRC", %w[BOOK], @document_holding) ||
      analyze_values(%w[01 02 09 10 20 23], "CPACT", %w[BOOK REFBK], @document_holding) ||
      analyze_values(%w[01 02 03 09 20 23 25], "NEWBK", %w[BOOK], @document_holding) ||
      analyze_values(%w[01 02 03 04 09 10 20 23 25], "OSIZE", %w[BOOK], @document_holding) ||
      analyze_values(COMMON_HEALTH_IDS, "RFDESK", %w[BOOK], @document_holding)
  end

  def book_iss_analyses(holding)
    analyze_values(%w[01 02 03 04 09 20 23 25], "PER", BOOK_ISS, holding) ||
      analyze_values(COMMON_HEALTH_IDS, "REF", BOOK_ISSBD_REFBK, holding) ||
      analyze_values(COMMON_IDS_2, "STACK", %w[BOOK ISS REFBK RESV], holding) ||
      analyze_values(%w[01 04 09 20 23 24 25], "STOR", BOOK_ISS, holding) ||
      analyze_values(%w[02], "STOR", BOOK_ISS_MLTVL, holding)
  end
end
