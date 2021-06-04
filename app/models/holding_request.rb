# frozen_string_literal: true
class HoldingRequest
  include ActiveModel::Model
  attr_accessor :mms_id, :pickup_library, :not_needed_after, :comment
  def initialize(mms_id)
    @mms_id = mms_id
  end
end
