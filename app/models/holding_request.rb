# frozen_string_literal: true
class HoldingRequest
  include ActiveModel::Model
  attr_accessor :mms_id, :holding_id, :pickup_library, :not_needed_after, :comment, :id, :user

  # Is there a way to pull labels from config/translation_maps?
  # Pickup libraries from spike, should be double checked
  def self.pickup_libraries
    [["Library Service Center", "LSC"],
     ["Robert W. Woodruff Library", "UNIV"],
     ["Goizueta Business Library", "BUS"],
     ["Marian K. Heilbrun Music Media", "MUSME"],
     ["Health Sciences Library", "HLTH"],
     ["Science Commons", "CHEM"],
     ["Pitts Theology Library", "THEO"],
     ["Law Library", "LAW"],
     ["Oxford College Library", "OXFD"],
     ["EMOL"],
     ["EUH Branch Library", "EUH"],
     ["Grady Branch Library", "GRADY"],
     ["EUHM Branch Library", "MID"],
     ["Rose Library (MARBL)", "MARBL"]]
  end

  def initialize(params = {})
    @id = params[:id]
    @mms_id = params[:mms_id]
    @pickup_library = params[:pickup_library]
    @user = params[:user]
    @holding_id = params[:holding_id]
    @comment = params[:comment]
    @not_needed_after = params[:not_needed_after]
  end

  def save
    if holding_request_response.code == 200
      holding_request_body = JSON.parse(holding_request_response.body).deep_symbolize_keys!
      @id = holding_request_body[:request_id]
      self
    else
      holding_request_response
    end
  end

  def self.find(params = {})
    hr = HoldingRequest.new(params)
    url = hr.find_request_url
    response = hr.find_request_response(url)
    body = JSON.parse(response.body).deep_symbolize_keys!
    hr.mms_id = body[:mms_id]
    hr.holding_id = body[:holding_id]
    hr.pickup_library = body[:pickup_location_library]
    hr.comment = body[:comment]
    hr
  end

  def find_request_response(url)
    RestClient.get(url, { content_type: :json, accept: :json })
  end

  def find_request_url
    "#{api_url}/almaws/v1/users/#{@user}/requests/#{id}?user_id_type=all_unique&apikey=#{api_user_key}"
  end

  def holding_request_response
    @holding_request_response ||= RestClient.post(title_request_url, request_object.to_json, { content_type: :json, accept: :json })
  end

  def request_object
    {
      "request_type": "HOLD",
      "holding_id": holding_id,
      "pickup_location_type": "LIBRARY",
      "pickup_location_library": pickup_library,
      "pickup_location_institution": "01GALI_EMORY",
      "comment": comment,
      "last_interest_date": not_needed_after
    }
  end

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def api_user_key
    ENV.fetch('ALMA_USER_KEY')
  end

  def title_request_url
    "#{api_url}/almaws/v1/users/#{@user}/requests?user_id_type=all_unique&mms_id=#{@mms_id}&allow_same_request=false&apikey=#{api_user_key}"
  end
end
