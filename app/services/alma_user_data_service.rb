# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaUserDataService
  def initialize(net_id)
    @net_id = net_id
    @user_data = pull_data
  end

  def first_email
    pulled_email = @user_data['user']['contact_info']['emails']&.values&.first if @user_data.present?
    return pulled_email['email_address'] if pulled_email.present?
    ''
  end

  def full_name
    @user_data.present? ? @user_data['user']['full_name'] : ''
  end

  private

    def pull_data
      response = RestClient.get("#{api_url}/almaws/v1/users/#{@net_id}#{query_string}")
      return Hash.from_xml(response) if Nokogiri.XML(response).errors.empty?
      {}
    rescue RestClient::BadRequest
      {}
    end

    def api_url
      ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
    end

    def user_api_key
      ENV.fetch('ALMA_USER_KEY')
    end

    def query_string
      "?apikey=#{user_api_key}"
    end
end
