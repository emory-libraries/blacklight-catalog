# frozen_string_literal: true
class HoldingRequestsController < ApplicationController
  before_action :authenticate_user!
  def new
    @holding_request = HoldingRequest.new
  end
end
