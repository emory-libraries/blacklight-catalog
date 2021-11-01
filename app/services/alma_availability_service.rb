# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaAvailabilityService
  def initialize(mms_ids)
    @mms_ids = mms_ids
  end

  def availability_of_documents
    return nil if @mms_ids.blank?

    response = query_availability
    return nil if response.blank?

    xml = Nokogiri::XML(response)
    bib_records = xml.xpath("//bib")
    ret_hsh = {}
    bib_records.each do |record|
      ret_hsh[record.xpath('mms_id').text] = {
        physical_exists: record.xpath('record/datafield[@tag="AVA"]').present?,
        physical_available: physical_any_available?(record),
        online_available: online_any_available?(record)
      }
    end
    ret_hsh
  end

  def query_availability
    RestClient.get "#{api_url}/almaws/v1/bibs?mms_id=#{@mms_ids.join('%2C')}#{query_inst}#{api_key}"
  rescue
    nil
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

  def physical_any_available?(record)
    phys_fields = record.xpath('record/datafield[@tag="AVA"]/subfield[@code="e"]')
    phys_fields.present? ? phys_fields.any? { |f| f.text.casecmp('available').zero? } : false
  end

  def online_any_available?(record)
    online_fields = record.xpath('record/datafield[@tag="AVE"]/subfield[@code="e"]')
    online_fields.present? ? online_fields.any? { |f| f.text.casecmp('available').zero? } : false
  end
end
