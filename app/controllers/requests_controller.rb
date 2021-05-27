# frozen_string_literal: true
class RequestsController < ApplicationController
  def index
    render json: my_json
  end

  def api_key
    ENV.fetch('ALMA_ALL_KEY')
  end

  def host
    ENV['ALMA_API_URL'] || "api-na.hosted.exlibrisgroup.com"
  end

  def holding
    # mms_id = params[:mms_id]
    mms_id = 9937241630902486
    holdings_url = "https://#{host}/almaws/v1/bibs/#{mms_id}/holdings?apikey=#{api_key}"
    response = RestClient.get(holdings_url)
    Nokogiri.XML(response.body)
  end

  def holding_id
    holding.xpath("//holdings/holding/holding_id").text
  end

  def holding_library
    holding.xpath("//holdings/holding/library").text
  end

  private

  def my_json
    # AlmaRequestService.new(params[:mms_id], current_user.uid)
    { uid: current_user.uid,
      holding_id: holding_id,
      holding_library: holding_library
    }
  end

  # def requests_params
  #   params.require().permit()
  # end
end
