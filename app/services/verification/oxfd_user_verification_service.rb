# frozen_string_literal: true

class Verification::OxfdUserVerificationService < Verification::IlliadVerificationService
  def document_delivery?
    analyze_values_from_location_array(
      %w[CIRC NEWBK OGTR ONFLY], COMMON_IDS_3, %w[BOOK], @document_holding
    ) ||
      analyze_values_from_location_array(
        %w[OSIZE STACK], COMMON_IDS_3, BOOK_ISS_REFBK, @document_holding
      ) ||
      analyze_values_from_location_array(
        %w[PER RESRV], COMMON_IDS_3, BOOK_ISS_RESV, @document_holding
      ) ||
      analyze_values(%w[01 02 03 04 09 20 23 24], "GRNOV", %w[BOOK], @document_holding) ||
      analyze_values(COMMON_IDS_3, "REF", %w[BOOK ISSUE REFBK], @document_holding)
  end
end
