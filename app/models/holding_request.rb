# frozen_string_literal: true
class HoldingRequest
  include ActiveModel::Model
  attr_accessor :mms_id, :holding_id, :pickup_library, :not_needed_after, :comment

  # Is there a way to pull labels from config/translation_maps?
  # Pickup libraries from spike, should be double checked
  def self.pickup_libraries
    [["Library Service Center", "LSC"],
     ["Robert W. Woodruff Library", "UNIV"],
     ["Goizueta Business Library", "BUS"],
     ["Marian K. Heilbrun Music Media", "MUSME"],
     ["Health Sciences Library", "HLTH"],
     ["Science Commons", "CHEM"],
     ["Pitts Theology Library", "THEO"],
     ["Law Library", "LAW"],
     ["Oxford College Library", "OXFD"],
     ["EMOL"],
     ["EUH Branch Library", "EUH"],
     ["Grady Branch Library", "GRADY"],
     ["EUHM Branch Library", "MID"],
     ["Rose Library (MARBL)", "MARBL"]]
  end

  def initialize(params = {})
    @mms_id = params[:mms_id]
    @pickup_library = params[:pickup_library]
    @user = params[:user]
    @holding_id = params[:holding_id]
  end

  def save; end
end
