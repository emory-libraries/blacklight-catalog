# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaAvailabilityService
  NAMESPACES = {
    "srw" => "http://www.loc.gov/zing/srw/",
    "marc" => "http://www.loc.gov/MARC21/slim"
  }.freeze

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
    RestClient.get "https://#{ENV['ALMA']}.alma.exlibrisgroup.com/view/sru/#{ENV['INSTITUTION']}?version=1.2&operation=searchRetrieve&recordSchema=marcxml&query=mms_id=#{@mms_ids.join('%20or%20mms_id=')}&maximumRecords=#{@mms_ids.count}"
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
    online_fields = record.xpath('.//marc:datafield[@tag="AVE"]', NAMESPACES)
    online_fields.present? ? online_fields.any? { |f| f.xpath('.//marc:subfield[@code="e"]', NAMESPACES).text.casecmp('available').zero? } : false
  end

  def process_availability(xml, ret_hsh)
    xml.xpath('//srw:record', NAMESPACES).each do |record|
      mms_id = record.xpath('.//marc:controlfield[@tag="001"]', NAMESPACES).text
      phys_holdings = record.xpath('.//marc:datafield[@tag="AVA"]', NAMESPACES)
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
        library: ph.xpath('.//marc:subfield[@code="q"]', NAMESPACES).text.strip,
        lib_location: ph.xpath('.//marc:subfield[@code="c"]', NAMESPACES).text.strip,
        call_number: ph.xpath('.//marc:subfield[@code="d"]', NAMESPACES).text.strip,
        status: ph.xpath('.//marc:subfield[@code="e"]', NAMESPACES).text.strip
      }
    end
  end
end
