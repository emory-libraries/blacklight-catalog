# frozen_string_literal: true

class Verification::IlliadVerificationService
  COMMON_IDS = %w[01 02 03 04 09 10 20 23].freeze
  COMMON_IDS_2 = %w[01 02 03 04 09 20 23].freeze
  COMMON_IDS_3 = %w[01 02 03 04 09 10 20 23 24].freeze
  COMMON_IDS_4 = %w[01 02 03 04 09 10 20 23 24 25].freeze
  COMMON_IDS_5 = %w[01 02 03 04 09 20 23 24 25].freeze
  COMMON_IDS_6 = %w[01 03 04 09 10 20 23 24 25].freeze
  BOOK_ISS = %w[BOOK ISSBD ISSUE].freeze
  OSIZE_BOOK_ISS = %w[OSIZE BOOK ISSBD ISSUE].freeze
  BOOK_ISSBD_REFBK = %w[BOOK ISSBD REFBK].freeze
  BDVOL_BOOK_ISS = %w[BDVOL BOOK ISSBD ISSUE].freeze
  BOOK_ISS_MLTVL = %w[BOOK ISSBD ISSUE MLTVL].freeze
  BOOK_ISSBD = %w[BOOK ISSBD].freeze
  BOOK_ISSUE_MLTVL_REFBK = %w[BOOK ISSUE MLTVL REFBK].freeze
  BOOK_ISS_REFBK = %w[BOOK ISSBD ISSUE REFBK].freeze
  BOOK_ISS_RESV = %w[BOOK ISSBD ISSUE RESV].freeze

  def initialize(user_group_id, document_holding)
    @user_group_id = user_group_id
    @document_holding = document_holding
  end

  def item_location(holding)
    holding[:location][:value]
  end

  def item_type_codes(holding)
    holding[:items]&.map { |i| i[:type_code] }&.compact&.uniq
  end

  def analyze_values(user_groups, location, expected_type_codes, holding)
    user_groups.include?(@user_group_id) && item_location(holding) == location && (expected_type_codes & item_type_codes(holding)).present?
  end

  def analyze_values_from_location_array(location_array, id_array, type_array, holding)
    location_array.any? do |location|
      analyze_values(id_array, location, type_array, holding)
    end
  end
end
