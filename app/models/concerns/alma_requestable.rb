# frozen_string_literal: true
module AlmaRequestable
  extend ActiveSupport::Concern

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

  def alma_response(url)
    RestClient.get url, { accept: :xml }
  end

  def parsed_response(response)
    Nokogiri::XML(response)
  end

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
end
