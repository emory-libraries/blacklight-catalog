# frozen_string_literal: true
module Statusable
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

  # Documentation for availability field from Alma
  # https://knowledge.exlibrisgroup.com/Primo/Knowledge_Articles/What_does_each_subfield_in_the_AVA_tag_hold_when_records_are_extracted_from_Voyager_for_Primo%3F
  def full_record
    Nokogiri::XML(record_response)
  end

  def items_by_holding_record(holding_id, user = nil)
    Nokogiri::XML(items_by_holding_response(holding_id, user))
  end

  def record_response
    @record_response ||= RestClient.get full_record_url, { accept: :xml }
  end

  def items_by_holding_response(holding_id, user = nil)
    RestClient.get items_by_holding_url(holding_id, user), { accept: :xml }
  end

  def full_record_url
    "#{api_url}/almaws/v1/bibs/#{mms_id}#{query_inst}#{api_bib_key}"
  end

  def items_by_holding_url(holding_id, user = nil)
    "#{api_url}/almaws/v1/bibs/#{mms_id}#{items_by_holding_query(holding_id, user)}#{api_bib_key}"
  end

  def items_by_holding_query(holding_id, user = nil)
    if user.blank? || user&.guest
      "/holdings/#{holding_id}/items?expand=due_date_policy&user_id=GUEST&apikey="
    else
      "/holdings/#{holding_id}/items?expand=due_date_policy&user_id=#{user.uid}&apikey="
    end
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

  def hold_requestable?(_user = nil)
    physical_holdings.present?
  end

  def physical_holding_values(availability)
    @availability_phrase = availability.at_xpath('subfield[@code="e"]')&.inner_text
    @copies = availability.at_xpath('subfield[@code="f"]')&.inner_text&.to_i
    unavailable = availability.at_xpath('subfield[@code="g"]')&.inner_text&.to_i
    @available = (@copies - unavailable if @copies)
    @holding_id = availability.at_xpath('subfield[@code="8"]')&.inner_text
    @library_label = availability.at_xpath('subfield[@code="q"]')&.inner_text
    @library_code = availability.at_xpath('subfield[@code="b"]')&.inner_text
    @location_code = availability.at_xpath('subfield[@code="j"]')&.inner_text
    @location_label = availability.at_xpath('subfield[@code="c"]')&.inner_text
    @call_number = availability.at_xpath('subfield[@code="d"]')&.inner_text
  end

  def items_by_holding_values(holding_id, user = nil)
    items = []
    holding_items = items_by_holding_record(holding_id, user)
    holding_items.xpath("//item/item_data").each do |node|
      item_info = {
        barcode: node.xpath("barcode")&.inner_text,
        type: node.xpath("physical_material_type").attr("desc")&.value,
        policy: item_policy(node, user),
        description: node.xpath("description")&.inner_text,
        status: node.xpath('base_status').attr("desc")&.value
      }
      items.append(item_info)
    end
    items
  end

  def item_policy(node, user)
    if user.blank? || user&.guest
      node.xpath('policy').attr("desc")&.value
    else
      node.xpath('due_date_policy')&.inner_text
    end
  end

  def physical_holding_hash(availability, user = nil)
    physical_holding_values(availability)
    {
      holding_id: @holding_id,
      library: { label: @library_label, value: @library_code },
      location: { label: @location_label, value: @location_code },
      call_number: @call_number,
      availability: {
        copies: @copies,
        available: @available,
        requests: requests(@holding_id),
        availability_phrase: @availability_phrase
      },
      items_by_holding: items_by_holding_values(@holding_id, user)
    }
  end

  def online_holdings
    return [] if online_from_availability.blank?
    online_from_availability.map do |entry|
      url_hash = JSON.parse(entry)
      # TODO: Can remove conditional once re-index is completed, and just keep the "if" portion
      if url_hash.keys.include?("url")
        url_hash.symbolize_keys!
      else
        { url: url_hash.keys.first, label: url_hash.values.first }
      end
    end
  end

  def physical_holdings(user = nil)
    return nil unless raw_physical_availability
    raw_physical_availability.map { |availability| physical_holding_hash(availability, user) }
  end

  def online_from_availability
    ave_availability = full_record.xpath('bib/record/datafield[@tag="AVE"]')
    ret_array = ave_availability.reduce([]) do |memo, value|
      next memo unless ave_u_8_present?(ave_availability)
      memo << {
        "label" => value.at_xpath('subfield[@code="m"]')&.text || value.at_xpath('subfield[@code="n"]')&.text || value.at_xpath('subfield[@code="t"]')&.text,
        "url" => build_ave_url(value.at_xpath('subfield[@code="8"]').text)
      }.to_json
    end
    url_fulltext.present? ? url_fulltext + ret_array : ret_array
  end

  def ave_u_8_present?(availability)
    availability.at_xpath('subfield[@code="u"]').present? && availability.at_xpath('subfield[@code="8"]').present?
  end

  def build_ave_url(portfolio_id)
    "#{alma_openurl_base}/discovery/openurl#{ave_query}#{portfolio_id}"
  end

  def ave_query
    "?institution=#{alma_institution}&vid=#{alma_institution}:blacklight&u.ignore_date_coverage=true&force_direct=true&portfolio_pid="
  end
end
