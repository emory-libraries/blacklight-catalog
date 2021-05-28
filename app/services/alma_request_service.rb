# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaRequestService
  def initialize(mms_id, uid)
    @uid = uid
    @mms_id = mms_id
    @response = query_holding
    @xml = Nokogiri::XML(@response)
    @req_options = req_options
    @json_response = json_response(uid)
  end

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def api_key
    ENV.fetch('ALMA_BIB_KEY')
  end

  def query_holding
    holdings_url = "#{api_url}/almaws/v1/bibs/#{@mms_id}/holdings?apikey=#{api_key}"
    RestClient.get(holdings_url)
  end

  def req_options
    url = "#{api_url}/almaws/v1/bibs/#{@mms_id}/request-options?user_id=#{@uid}&consider_dlr=false&apikey=#{api_key}"
    response = RestClient.get(url)
    xml = Nokogiri::XML(response.body)
    xml.xpath("//request_options/request_option/type[text()='HOLD']")
  end

  def holding_id
    @xml.xpath("//holdings/holding/holding_id").text
  end

  def holding_library
    @xml.xpath("//holdings/holding/library").text
  end

  def json_response(uid)
    { uid: uid,
      holding_id: holding_id,
      holding_library: holding_library }
  end
end
