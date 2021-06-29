# frozen_string_literal: true

class Verification::MusmeUserVerificationService < Verification::IlliadVerificationService
  def document_delivery?
    analyze_values_from_location_array(
      %w[NEWBK REF], COMMON_IDS, BOOK_ISSUE_MLTVL_REFBK, @document_holding
    ) ||
      analyze_values(COMMON_IDS_2, "STACK", BOOK_ISS_REFBK, @document_holding) ||
      analyze_values(COMMON_IDS_5, "STOR", BOOK_ISS, @document_holding)
  end
end
