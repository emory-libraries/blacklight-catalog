# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaAvailabilityService
  def initialize(mms_ids)
    @mms_ids = mms_ids
  end

  def availability_of_documents
    return if @mms_ids.blank?
    response = query_availability
    xml = Nokogiri::XML(response)
    bib_records = xml.xpath("//bib")
    ret_hsh = {}
    bib_records.each do |record|
      ret_hsh[record.xpath('mms_id').text] = {
        physical_exists: record.xpath('record/datafield[@tag="AVA"]').present?,
        physical_available: record.xpath('record/datafield[@tag="AVA"]/subfield[@code="e"]')&.text&.downcase == 'available',
        online_available: record.xpath('record/datafield[@tag="AVE"]/subfield[@code="e"]')&.text&.downcase == 'available'
      }
    end
    ret_hsh
  end

  def query_availability
    RestClient.get "#{api_url}/almaws/v1/bibs?mms_id=#{@mms_ids.join('%2C')}#{query_inst}#{api_key}"
  end

  def query_inst
    "&view=full&expand=p_avail,e_avail,d_avail&apikey="
  end

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def api_key
    ENV.fetch('ALMA_BIB_KEY')
  end
end
