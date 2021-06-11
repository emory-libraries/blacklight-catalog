# frozen_string_literal: true
module Statusable
  extend ActiveSupport::Concern

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def api_bib_key
    ENV.fetch('ALMA_BIB_KEY')
  end

  # Documentation for availability field from Alma
  # https://knowledge.exlibrisgroup.com/Primo/Knowledge_Articles/What_does_each_subfield_in_the_AVA_tag_hold_when_records_are_extracted_from_Voyager_for_Primo%3F
  def full_record
    Nokogiri::XML(record_response)
  end

  def holding_view(holding_id)
    Nokogiri::XML(holding_response(holding_id))
  end

  def record_response
    @record_response ||= RestClient.get full_record_url, { accept: :xml }
  end

  def holding_response(holding_id)
    RestClient.get holding_view_url(holding_id), { accept: :xml }
  end

  def full_record_url
    "#{api_url}/almaws/v1/bibs/#{id}#{query_inst}#{api_bib_key}"
  end

  def holding_view_url(holding_id)
    "#{api_url}/almaws/v1/bibs/#{id}#{holding_query(holding_id)}#{api_bib_key}"
  end

  def holding_query(holding_id)
    "/holdings/#{holding_id}/items?apikey="
  end

  def query_inst
    "?view=full&expand=p_avail,e_avail,d_avail,requests&apikey="
  end

  def raw_physical_availability
    raw_availability = full_record.xpath('bib/record/datafield[@tag="AVA"]')
    return nil if raw_availability.empty?
    raw_availability
  end

  def requests?
    full_record.xpath("bib/requests").inner_text.to_i.positive?
  end

  def requests(holding_id)
    requests? == false ? 0 : retrieve_requests(holding_id)
  end

  def retrieve_requests(holding_id)
    base_requests_link = full_record.at_xpath('bib/requests').attributes["link"].value
    url = base_requests_link + "?status=active&apikey=#{api_bib_key}"
    response = RestClient.get url, { accept: :xml }
    body = Nokogiri::XML(response)
    request_holding_id = body.at_xpath('user_requests/user_request/holding_id')&.inner_text
    if holding_id == request_holding_id
      1
    else
      0
    end
  end

  def physical_item_values(availability)
    @availability_phrase = availability.at_xpath('subfield[@code="e"]')&.inner_text
    @copies = availability.at_xpath('subfield[@code="f"]')&.inner_text&.to_i
    unavailable = availability.at_xpath('subfield[@code="g"]')&.inner_text&.to_i
    @available = (@copies - unavailable if @copies)
    @holding_id = availability.at_xpath('subfield[@code="8"]')&.inner_text
    @library = availability.at_xpath('subfield[@code="q"]')&.inner_text
    @location = availability.at_xpath('subfield[@code="c"]')&.inner_text
    @call_number = availability.at_xpath('subfield[@code="d"]')&.inner_text
  end

  def holding_items_values(holding_id)
    items = []
    holding_items = holding_view(holding_id)
    holding_items.xpath("//item").each do |node|
      item_info = {
        barcode: node.xpath("item_data/barcode")&.inner_text,
        type: node.xpath("item_data/physical_material_type").attr("desc")&.value,
        policy: node.xpath('item_data/policy').attr("desc")&.value,
        status: node.xpath('item_data/base_status').attr("desc")&.value
      }
      items.append(item_info)
    end
    items
  end

  def physical_item_hash(availability)
    physical_item_values(availability)
    {
      holding_id: @holding_id,
      library: @library,
      location: @location,
      call_number: @call_number,
      availability: {
        copies: @copies,
        available: @available,
        requests: requests(@holding_id),
        availability_phrase: @availability_phrase
      },
      holding_view: holding_items_values(@holding_id)
    }
  end

  def online_holdings
    return nil unless url_fulltext
    url_fulltext.map do |entry|
      url_hash = JSON.parse(entry)
      # TODO: Can remove conditional once re-index is completed, and just keep the "if" portion
      if url_hash.keys.include?("url")
        url_hash.symbolize_keys!
      else
        { url: url_hash.keys.first, label: url_hash.values.first }
      end
    end
  end

  def physical_holdings
    return nil unless raw_physical_availability
    raw_physical_availability.map { |availability| physical_item_hash(availability) }
  end
end
