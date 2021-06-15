# frozen_string_literal: true
class HoldRequestsController < ApplicationController
  before_action :authenticate_user!
  def new
    # @hold_request = HoldRequest.new({
    #                                   title: params[:title], mms_id: params[:mms_id], holding_id: params[:holding_id],
    #                                   holding_library: { label: params[:holding_library].try(:[], :label), value: params[:holding_library].try(:[], :value) },
    #                                   holding_location: { label: params[:holding_location].try(:[], :label), value: params[:holding_location].try(:[], :value) },
    #                                   user: current_user
    #                                 })
    @hold_request = HoldRequest.new(hold_request_params.merge(user: current_user))
  end

  def show
    @hold_request = HoldRequest.find({ id: params[:id], user: current_user })
  end

  def create
    @hold_request = HoldRequest.new({ mms_id: params["hold_request"]["mms_id"],
                                      holding_id: params["hold_request"]["holding_id"],
                                      pickup_library: params["hold_request"]["pickup_library"],
                                      comment: params["hold_request"]["comment"],
                                      not_needed_after: not_needed_after,
                                      user: current_user })
    if @hold_request.valid?
      @hold_request.save
      flash[:notice] = 'Hold request was successfully created.'
      redirect_to hold_request_path @hold_request.id
    else
      flash[:errors] = @hold_request.errors.full_messages
      redirect_to new_hold_request_path(hold_request: hold_request_params)
    end
  end

  private

  def hold_request_params
    params.require(:hold_request).permit(:id, :mms_id, :title, :holding_id, :pickup_library, :not_needed_after, :comment, :user, :holding_library, :holding_location)
  end

  def not_needed_after
    year = params["hold_request"]["not_needed_after(1i)"].to_i
    month = params["hold_request"]["not_needed_after(2i)"].to_i
    day = params["hold_request"]["not_needed_after(3i)"].to_i
    date = Date.new(year, month, day)
    date.strftime("%Y-%m-%dZ")
  end
end
