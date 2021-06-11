# frozen_string_literal: true
class HoldingRequestsController < ApplicationController
  before_action :authenticate_user!
  def new
    @holding_request = HoldingRequest.new({
                                            mms_id: params[:mms_id], holding_id: params[:holding_id],
                                            holding_library: { label: params[:holding_library].try(:[], :label), value: params[:holding_library].try(:[], :value) },
                                            holding_location: { label: params[:holding_location].try(:[], :label), value: params[:holding_location].try(:[], :value) },
                                            user: current_user
                                          })
  end

  def show
    @holding_request = HoldingRequest.find({ id: params[:id], user: current_user })
  end

  def create
    @holding_request = HoldingRequest.new({ mms_id: params["holding_request"]["mms_id"],
                                            holding_id: params["holding_request"]["holding_id"],
                                            pickup_library: params["holding_request"]["pickup_library"],
                                            comment: params["holding_request"]["comment"],
                                            not_needed_after: not_needed_after,
                                            user: current_user })
    if @holding_request.save
      redirect_to holding_request_path @holding_request.id
    else
      render :new
    end
  end

  private

  def not_needed_after
    year = params["holding_request"]["not_needed_after(1i)"].to_i
    month = params["holding_request"]["not_needed_after(2i)"].to_i
    day = params["holding_request"]["not_needed_after(3i)"].to_i
    date = Date.new(year, month, day)
    date.strftime("%Y-%m-%dZ")
  end
end
