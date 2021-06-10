# frozen_string_literal: true
class HoldingRequest
  include ActiveModel::Model
  attr_accessor :mms_id, :holding_id, :pickup_library, :not_needed_after, :comment, :id, :user, :holding_library

  # Is there a way to pull labels from config/translation_maps?
  # Pickup libraries from spike, should be double checked
  def self.pickup_libraries
    [{ label: "Library Service Center", value: "LSC" },
     { label: "Robert W. Woodruff Library", value: "UNIV" },
     { label: "Goizueta Business Library", value: "BUS" },
     { label: "Marian K. Heilbrun Music Media", value: "MUSME" },
     { label: "Health Sciences Library", value: "HLTH" },
     { label: "Science Commons", value: "CHEM" },
     { label: "Pitts Theology Library", value: "THEO" },
     { label: "Law Library", value: "LAW" },
     { label: "Oxford College Library", value: "OXFD" },
     { label: "EMOL", value: nil },
     { label: "EUH Branch Library", value: "EUH" },
     { label: "Grady Branch Library", value: "GRADY" },
     { label: "EUHM Branch Library", value: "MID" },
     { label: "Rose Library (MARBL)", value: "MARBL" }]
  end

  def pickup_library_options
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
    @holding_library = params[:holding_library]
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
      "pickup_location_institution": "01GALI_EMORY"
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
