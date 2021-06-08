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
    begin
      @holding_request.save
      redirect_to @holding_request, notice: 'Holding request was successfully created.'
    rescue RestClient::BadRequest=>x
      flash[:error]= JSON.parse(x.response)['errorList']["error"].map{|x| x['errorMessage']}.join(", ")
      render :new 
    end
  end
end
