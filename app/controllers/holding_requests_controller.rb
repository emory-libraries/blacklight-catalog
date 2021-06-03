# frozen_string_literal: true
class HoldingRequestsController < ApplicationController
  def new
    @holding_request = HoldingRequest.new
  end
end
