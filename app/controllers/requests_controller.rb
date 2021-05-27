# frozen_string_literal: true
class RequestsController < ApplicationController
  def index
    render json: AlmaRequestService.new(params[:mms_id], current_user.uid)
  end
end
