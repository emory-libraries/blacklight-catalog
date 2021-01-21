# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaAvailabilityService
  def initialize(mms_id)
    @mms_id = mms_id
    @response = query_availability
    @xml = Nokogiri::XML(@response)
  end

  def current_availability
    bib = {}
    physical = @xml.at_xpath('bib/record/datafield[@tag="AVA"]/subfield[@code="e"]')
    digital = @xml.at_xpath('bib/record/datafield[@tag="AVD"]')
    electronic = @xml.at_xpath('bib/record/datafield[@tag="AVE"]')
    bib[@mms_id] =
      { physical: {
        exists: physical ? true : false,
        available: physical && physical.text == 'available' ? true : false
      },
        online: { exists: digital || electronic ? true : false } }
    bib
  end

  def query_availability
    RestClient.get api_url + "/almaws/v1/bibs/" + @mms_id + query_inst + api_key
  end

  def query_inst
    "?view=full&expand=p_avail,e_avail,d_avail&apikey="
  end

  def api_url
    ENV['alma_api_url'] || 'www.example.com'
  end

  def api_key
    ENV['alma_api_key'] || ""
  end
end
