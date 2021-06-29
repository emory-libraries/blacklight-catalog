# frozen_string_literal: true

class Verification::LawUserVerificationService < Verification::IlliadVerificationService
  def document_delivery?
    analyze_values(%w[01 03 09 10 12 20 23], "STACK", %w[BOOK GVDOC ISSBD ISSUE REFBK LSLF], @document_holding)
  end
end
