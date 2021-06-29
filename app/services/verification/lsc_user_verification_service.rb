# frozen_string_literal: true

class Verification::LscUserVerificationService < Verification::IlliadVerificationService
  LSC_COMMON = %w[01 02 03 04 10 20 22 23 24 25].freeze

  def document_delivery?
    location_array_analyses(@document_holding) ||
      book_analyses(@document_holding) ||
      analyze_values(COMMON_IDS_3, "MSTOR", %w[BOOK SCORE], @document_holding) ||
      analyze_values(COMMON_IDS_3, "TSTOR", %w[ISSBD ISSUE SCORE], @document_holding) ||
      analyze_values(COMMON_IDS_3, "USTOR", %w[BOOK ISSBD SCORE], @document_holding) ||
      analyze_values(%w[01 09 10 20 23], "USTORJ", %w[ISSBD], @document_holding)
  end

  def location_array_analyses(holding)
    analyze_values_from_location_array(%w[HSTORJ MSTORJ SSTORJ TSTORJ USTORJ], COMMON_IDS_3, BOOK_ISS, holding) ||
      analyze_values_from_location_array(%w[HSTOR MSTORNC SSTOR], COMMON_IDS_3, BOOK_ISSBD, holding) ||
      analyze_values_from_location_array(%w[USTORGD USTORNC], LSC_COMMON, %w[BOOK FICHE FILM GOVRECORD ISSBD ISSUE], holding) ||
      analyze_values_from_location_array(%w[BSTORJ HSTORNC], COMMON_IDS_3, %w[ISSBD], holding)
  end

  def book_analyses(holding)
    analyze_values(COMMON_IDS_3, "BSTOR", %w[BOOK], holding) ||
      analyze_values(%w[01 02 04 09 10 20 23 24], "TSTOR", %w[BOOK], holding) ||
      analyze_values(COMMON_IDS_4, "USTOR", %w[BOOK], holding)
  end
end
