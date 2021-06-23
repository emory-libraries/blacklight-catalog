# frozen_string_literal: true
module AlmaRequestable
  extend ActiveSupport::Concern

  def bib_record(url)
    @bib_record ||= begin
      response = alma_response(url)
      parsed_response(response)
    end
  end

  # Currently, if we follow the pattern in bib and request records, the object does not update when the user logs in
  def item_record(url)
    response = alma_response(url)
    parsed_response(response)
  end

  def request_record(url)
    @request_record ||= begin
      response = alma_response(url)
      parsed_response(response)
    end
  end

  def alma_response(url)
    RestClient.get url, { accept: :xml }
  end

  def parsed_response(response)
    Nokogiri::XML(response)
  end

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def api_bib_key
    ENV.fetch('ALMA_BIB_KEY')
  end

  def alma_openurl_base
    ENV.fetch('ALMA_BASE_SANDBOX_URL')
  end

  def alma_institution
    ENV.fetch('INSTITUTION')
  end

  def full_record_url
    "#{base_url}#{full_record_query}#{bib_key_phrase}"
  end

  def base_url
    "#{api_url}/almaws/v1/bibs/#{mms_id}"
  end

  def bib_key_phrase
    "apikey=#{api_bib_key}"
  end

  def items_by_holding_url(holding_id, user = nil)
    "#{base_url}#{items_by_holding_query(holding_id, user)}#{bib_key_phrase}"
  end

  def items_by_holding_query(holding_id, user = nil)
    "/holdings/#{holding_id}/items?expand=due_date_policy&user_id=#{user_id(user)}&"
  end

  def user_id(user)
    user.blank? || user&.guest ? "GUEST" : user.uid
  end

  def full_record_query
    "?view=full&expand=p_avail,e_avail,d_avail,requests&"
  end
end
