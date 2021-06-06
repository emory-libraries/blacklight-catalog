# frozen_string_literal: true
class HoldingRequestsController < ApplicationController
  before_action :authenticate_user!
  def new
    @holding_request = HoldingRequest.new({ holding_id: params[:holding_id] })
  end

  def show; end

  def create
    @holding_request = HoldingRequest.new({ holding_id: params["holding_request"]["mms_id"],
                                            pickup_library: params["holding_request"]["pickup_library"], user: current_user.uid })
    respond_to do |format|
      if @holding_request.save
        format.html { redirect_to @@holding_request, notice: 'Holding request was successfully created.' }
        format.json { render :show, status: :created, location: @@holding_request }
      else
        format.html { render :new }
        format.json { render json: @@holding_request.errors, status: :unprocessable_entity }
      end
    end
  end
end
