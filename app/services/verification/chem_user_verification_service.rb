# frozen_string_literal: true

class Verification::ChemUserVerificationService < Verification::IlliadVerificationService
  def document_delivery?
    analyze_values(COMMON_IDS, "NEWBK", BOOK_ISSBD_REFBK, @document_holding) ||
      analyze_values(%w[01 02 09 20 23], "REF", %w[REFBK], @document_holding) ||
      analyze_values(%w[03], "REF", BDVOL_BOOK_ISS, @document_holding) ||
      analyze_values(COMMON_IDS, "STACK", BOOK_ISS, @document_holding) ||
      analyze_values(%w[01 03 04 09 20 23 24 25], "STOR", BOOK_ISS, @document_holding)
  end
end
