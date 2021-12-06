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
    ret_hsh = {}

    process_availability(xml, ret_hsh)
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

  def online_any_available?(record)
    online_fields = record.xpath('record/datafield[@tag="AVE"]/subfield[@code="e"]')
    online_fields.present? ? online_fields.any? { |f| f.text.casecmp('available').zero? } : false
  end

  def process_availability(xml, ret_hsh)
    xml.xpath("//bib").each do |record|
      mms_id = record.xpath('mms_id').text
      phys_holdings = record.xpath('record/datafield[@tag="AVA"]')
      ret_hsh[mms_id] = {
        online_available: online_any_available?(record),
        physical_holdings: []
      }
      process_phys_holdings(phys_holdings, ret_hsh, mms_id)
    end
  end

  def process_phys_holdings(phys_holdings, ret_hsh, mms_id)
    phys_holdings.each do |ph|
      ret_hsh[mms_id][:physical_holdings] << {
        library: ph.xpath('subfield[@code="q"]').text&.strip,
        lib_location: ph.xpath('subfield[@code="c"]').text&.strip,
        call_number: ph.xpath('subfield[@code="d"]').text&.strip,
        status: ph.xpath('subfield[@code="e"]').text&.strip
      }
    end
  end
end
