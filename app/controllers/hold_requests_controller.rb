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
    @hold_request = HoldRequest.new(hold_request_params.merge(user: current_user))
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
end
