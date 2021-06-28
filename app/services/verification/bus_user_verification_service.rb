# frozen_string_literal: true

class Verification::BusUserVerificationService < Verification::IlliadVerificationService
  def document_delivery?
    analyze_values(COMMON_IDS_6, "STOR", BOOK_ISS, @document_holding) ||
      analyze_values(COMMON_IDS, "STACK", OSIZE_BOOK_ISS, @document_holding)
  end
end
