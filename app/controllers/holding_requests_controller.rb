# frozen_string_literal: true
class HoldingRequestsController < ApplicationController
  before_action :authenticate_user!
  def new
    @holding_request = HoldingRequest.new({ mms_id: params[:mms_id], holding_id: params[:holding_id] })
  end

  def show
    @holding_request = HoldingRequest.find({ id: params[:id], user: current_user.uid })
  end

  def create
    @holding_request = HoldingRequest.new({ mms_id: params["holding_request"]["mms_id"],
                                            holding_id: params["holding_request"]["holding_id"],
                                            pickup_library: params["holding_request"]["pickup_library"],
                                            user: current_user.uid })
    respond_to do |format|
      if @holding_request.save
        # How do we pass along the request_id through the redirect?
        format.html { redirect_to @holding_request, notice: 'Holding request was successfully created.' }
        format.json { render :show, status: :created, location: @holding_request }
      else
        format.html { render :new }
        format.json { render json: @holding_request.errors, status: :unprocessable_entity }
      end
    end
  end
end
