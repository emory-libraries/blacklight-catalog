# frozen_string_literal: true
class HoldRequest
  include ActiveModel::Model
  attr_accessor :mms_id, :holding_id, :pickup_library, :not_needed_after, :comment, :id, :user, :holding_library, :holding_location, :title

  def initialize(params = {})
    @id = params[:id]
    @title = params[:title]
    @mms_id = params[:mms_id]
    @pickup_library = params[:pickup_library]
    @user = params[:user]
    @holding_id = params[:holding_id]
    @comment = params[:comment]
    @not_needed_after = params[:not_needed_after]
    @holding_library = params[:holding_library]
    @holding_location = params[:holding_location]
  end

  # Is there a way to pull labels from config/translation_maps?
  # Pickup libraries from spike, should be double checked
  def self.pickup_libraries
    [
      { label: "Health Sciences Library", value: "HLTH" },
      { label: "Law Library", value: "LAW" },
      { label: "Library Service Center", value: "LSC" },
      { label: "Marian K. Heilbrun Music Media", value: "MUSME" },
      { label: "Oxford College Library", value: "OXFD" },
      { label: "Pitts Theology Library", value: "THEO" },
      { label: "Robert W. Woodruff Library", value: "UNIV" },
      { label: "Robert W. Woodruff Library Outdoor Lockers", value: "UNIVLOCK" }
    ]
  end

  def pickup_library_options
    if @user.oxford_user?
      oxford_user_pickup_library_options
    elsif holding_library[:value] == "MUSME" && restricted_location?
      [{ label: "Marian K. Heilbrun Music Media", value: "MUSME" }]
    else
      HoldRequest.pickup_libraries
    end
  end

  def oxford_user_pickup_library_options
    if holding_library[:value] == "OXFD"
      [{ label: "Oxford College Library", value: "OXFD" }]
    elsif holding_library[:value] == "MUSME"
      oxford_user_music_options
    else
      HoldRequest.pickup_libraries
    end
  end

  def oxford_user_music_options
    if holding_location[:value] == "7DEQUIP"
      [{ label: "Marian K. Heilbrun Music Media", value: "MUSME" }]
    else
      [{ label: "Oxford College Library", value: "OXFD" }]
    end
  end

  def restricted_location?
    restricted_locations.include?(holding_location[:value])
  end

  def restricted_locations
    %w[DVDL MEDIA MEDIAOSIZE 7DEQUIP]
  end

  def save
    if hold_request_response.code == 200
      hold_request_body = JSON.parse(hold_request_response.body).deep_symbolize_keys!
      @id = hold_request_body[:request_id]
      self
    else
      hold_request_response
    end
  end

  def self.find(params = {})
    hr = HoldRequest.new(params)
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

  def hold_request_response
    @hold_request_response ||= RestClient.post(title_request_url, request_object.to_json, { content_type: :json, accept: :json })
  end

  def request_object
    {
      "request_type": "HOLD",
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
