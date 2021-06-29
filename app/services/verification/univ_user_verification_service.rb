# frozen_string_literal: true

class Verification::UnivUserVerificationService < Verification::IlliadVerificationService
  def document_delivery?
    book_iss_analyses(@document_holding) || book_iss_mltvl_analyses(@document_holding) ||
      analyze_values_from_location_array(%w[REF REFOV], COMMON_IDS_4, BDVOL_BOOK_ISS, @document_holding) ||
      analyze_values(COMMON_IDS_4, "CPER", %w[BDVOL ISSBD ISSUE], @document_holding) ||
      analyze_values(COMMON_IDS_4, "NEWBK", %w[BOOK], @document_holding) ||
      analyze_values(%w[01 02 09 20 23 24], "STDOC", %w[BOOK MLTVL], @document_holding)
  end

  def book_iss_analyses(holding)
    analyze_values_from_location_array(%w[OSIZE ULFO], COMMON_IDS_5, BOOK_ISS, holding) ||
      analyze_values(%w[10], "STDOC", BOOK_ISS, holding) ||
      analyze_values(COMMON_IDS_6, "STO96", BOOK_ISS, holding) ||
      analyze_values(%w[02 04 25], "STOR", BOOK_ISS, holding)
  end

  def book_iss_mltvl_analyses(holding)
    analyze_values(COMMON_IDS_4, "STACK", BOOK_ISS_MLTVL, holding) ||
      analyze_values(%w[01 03 09 10 20 23 24 25], "STOR", BOOK_ISS_MLTVL, holding)
  end
end
