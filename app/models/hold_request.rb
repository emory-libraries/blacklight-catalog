# frozen_string_literal: true
class HoldRequest
  include ActiveModel::Model
  include Statusable
  validates :pickup_library, presence: true
  validates :mms_id, presence: true
  validate :validate_physical_holdings
  # validates :physical_holdings, presence: true
  attr_accessor :mms_id, :holding_id, :pickup_library, :not_needed_after, :comment, :id, :user, :title

  def initialize(params = {})
    @id = params[:id]
    @title = params[:title]
    @mms_id = params[:mms_id]
    @pickup_library = params[:pickup_library]
    @user = params[:user]
    @holding_id = params[:holding_id]
    @comment = params[:comment]
    @not_needed_after = params[:not_needed_after]
  end

  def validate_physical_holdings
    return false if mms_id.blank?
    errors.add(:physical_holdings, "This object has no physical holdings to be requested") if physical_holdings.blank?
  end

  # Is there a way to pull labels from config/translation_maps?
  def self.pickup_libraries
    [
      { label: "Science Commons", value: "CHEM" },
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

  def holding_libraries
    physical_holdings.map { |holding| holding[:library].try(:[], :value) }
  end

  def holding_to_request
    raise StandardError, "No physical holdings to request" unless physical_holdings
    if physical_holdings.count == 1
      physical_holdings.first
    # elsif @user.oxford_user?
    #   byebug
    else
      priority_scores = physical_holdings.map do |holding|
        source_library_priority_list.index(holding[:library][:value])
      end
      priority_holding_index = priority_scores.index(priority_scores.min)
      physical_holdings[priority_holding_index]
    end
  end

  def source_library_priority_list
    %w[LSC UNIV BUS MUSME HLTH CHEM THEO LAW OXFD EMOL EUH GRADY MID MARBL]
  end

  def holding_library
    holding_to_request[:library]
  end

  def holding_location
    holding_to_request[:location]
  end

  def pickup_library_options
    if @user.oxford_user?
      oxford_user_pickup_library_options
    elsif holding_libraries.include?("MUSME") && restricted_location?
      [{ label: "Marian K. Heilbrun Music Media", value: "MUSME" }]
    else
      HoldRequest.pickup_libraries
    end
  end

  def oxford_user_pickup_library_options
    if holding_libraries.include?("OXFD") || holding_libraries.include?("MUSME")
      [{ label: "Oxford College Library", value: "OXFD" }]
    else
      HoldRequest.pickup_libraries
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
      "holding_id": holding_to_request[:holding_id],
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
