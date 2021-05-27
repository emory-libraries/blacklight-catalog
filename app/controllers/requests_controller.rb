# frozen_string_literal: true
class RequestsController < ApplicationController
  def index
    render json: json_response
  end

  def json_response
    AlmaRequestService.new(params[:mms_id], current_user.uid).json_response(current_user.uid)
  end
end
