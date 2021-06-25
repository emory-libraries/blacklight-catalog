# frozen_string_literal: true
class HoldRequestsController < ApplicationController
  before_action :authenticate_user!
  def new
    @hold_request = HoldRequest.new(hold_request_params.merge(user: current_user))
  end

  def show
    @hold_request = HoldRequest.find({ id: params[:id], user: current_user })
  end

  def create
    @hold_request = HoldRequest.new(hold_request_params.merge(user: current_user))
    if @hold_request.valid?
      @hold_request.save
      flash[:notice] = 'Hold request was successfully created.'
      redirect_to hold_request_path @hold_request.id
    else
      flash[:errors] = @hold_request.errors.full_messages
      redirect_to new_hold_request_path(hold_request: hold_request_params)
    end
  rescue RestClient::Exception => x
    flash[:error] = JSON.parse(x.response)["errorList"]["error"].map { |y| y["errorMessage"] }.join("<br/>")
    render :new
  end

  private

  def hold_request_params
    params.require(:hold_request).permit(:id, :mms_id, :title, :holding_id, :pickup_library, :not_needed_after, :comment, :user, :holding_library, :holding_location, :holding_item_id)
  end
end
