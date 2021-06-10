# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaVerificationService
  def initialize(net_id, password)
    @net_id = net_id
    @password = password
  end

  def verified?
    response = RestClient.post("#{api_url}/almaws/v1/users/#{@net_id}#{query_string}", '', {})
    response.code == 204
  rescue RestClient::BadRequest
    false
  end

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def user_api_key
    ENV.fetch('ALMA_USER_KEY')
  end

  def query_string
    "?user_id_type=all_unique&op=auth&password=#{@password}&apikey=#{user_api_key}"
  end
end
