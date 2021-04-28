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

  def current_avail_table_data(document)
    bib = {}
    physical = @xml.xpath('bib/record/datafield[@tag="AVA"]')
    online = @xml.xpath('bib/record/datafield[@tag="AVE"]/subfield[@code="e"]')

    bib[@mms_id] =
      { physical: {
        library: library_text(physical, document),
        call_number: call_number_text(physical),
        available: available_text(physical)
      },
        online: {
          links: build_online_items(document),
          uresolver: deliver_uresolver?(online)
        } }
    bib
  end

  def query_availability
    RestClient.get "#{api_url}/almaws/v1/bibs/#{@mms_id}#{query_inst}#{api_key}"
  end

  def query_inst
    "?view=full&expand=p_avail,e_avail,d_avail&apikey="
  end

  def api_url
    ENV['ALMA_API_URL'] || 'www.example.com'
  end

  def api_key
    ENV['ALMA_API_KEY'] || ""
  end

  def multiple_physical_items?(physical_arr)
    physical_arr.present? && physical_arr.count > 1
  end

  def library_text(physical_arr, document)
    multiple_physical_items?(physical_arr) ? 'Multiple libraries/locations' : single_lib_text(physical_arr, document)
  end

  def single_lib_text(physical_arr, document)
    library = physical_arr[0]&.at_xpath('subfield[@code="q"]')&.text
    section = physical_arr[0]&.at_xpath('subfield[@code="c"]')&.text
    solr_library = document['library_ssim'] - ['Library Service Center'] if document['library_ssim'].present?

    return "#{solr_library.first} (#{library})" if library_center?(library) && section.blank? && solr_library.present?
    return "#{library}: #{section}" if library.present?
    ''
  end

  def library_center?(library_text)
    library_text == 'Library Service Center'
  end

  def call_number_text(physical_arr)
    multiple_physical_items?(physical_arr) ? '-' : physical_arr[0]&.at_xpath('subfield[@code="d"]')&.text
  end

  def available_text(physical_arr)
    available_elements = physical_arr.xpath('subfield[@code="e"]').select { |el| el.text == 'available' }
    return '<span class="item-available">One or more copies available</span>' if available_elements.count > 1
    return '<span class="item-available">Available</span>' if available_elements.count == 1
    '<span class="item-not-available">No copies available</span>'
  end

  def build_online_items(document)
    build_array = []
    document.url_fulltext.each { |u| build_array << JSON.parse(u) } if document&.url_fulltext&.present?
    build_array
  end

  def deliver_uresolver?(online_arr)
    online_arr&.any? { |o| o.text.casecmp('available').zero? }
  end
end
