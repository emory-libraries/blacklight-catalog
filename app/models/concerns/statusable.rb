# frozen_string_literal: true

module Statusable
  extend ActiveSupport::Concern
  include SpecialCollectionsRequestable
  include DocumentDeliveryRequestable

  def physical_holdings(user = nil)
    return nil unless raw_physical_availability
    raw_physical_availability.map { |availability| physical_holding_hash(availability, user) }
  end

  def online_holdings
    return [] if raw_online_availability.blank?
    raw_online_availability.map do |online_availability|
      availability = JSON.parse(online_availability)
      availability.symbolize_keys!
    end
  end

  def hold_requestable?(user = nil)
    return false if physical_holdings(user).blank?
    date_policy_count = due_date_policies(user).count
    not_loanable_count = due_date_policies(user).count("Not loanable")
    # If there is a due date policy other than "Not loanable", the title is hold requestable
    if date_policy_count > not_loanable_count
      true
    else
      false
    end
  end

  def special_collections_requestable?(user = nil)
    holding_to_request(user).present?
  end

  def due_date_policies(user = nil)
    physical_holdings(user).map do |holding|
      holding[:items].map do |item|
        item[:policy][:due_date_policy]
      end
    end.flatten!
  end

  def raw_online_availability
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

  def raw_physical_availability
    raw_availability = full_record.xpath('bib/record/datafield[@tag="AVA"]')
    return nil if raw_availability.empty?
    raw_availability
  end

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def api_bib_key
    ENV.fetch('ALMA_BIB_KEY')
  end

  def alma_openurl_base
    ENV.fetch('ALMA_BASE_URL')
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
    items_record(user).xpath("//holding_id[text()='#{holding_id}']/parent::holding_data")
  end

  def record_response
    @record_response ||= RestClient.get full_record_url, { accept: :xml }
  end

  def items_record(user = nil)
    @items_record ||= begin
      first_page = Nokogiri::XML(items_response(user, 0))
      total_record_count = first_page.xpath("//items").attr("total_record_count").value.to_i
      if total_record_count <= 100
        first_page
      else
        combine_items_records(user, first_page, total_record_count)
      end
    end
  end

  def combine_items_records(user, first_page, total_record_count)
    record = first_page
    records_left = total_record_count - 100
    offset = 100
    while records_left.positive?
      next_page = Nokogiri::XML(items_response(user, offset))
      new_items = next_page.search('item')
      record.at('items').add_child(new_items)
      records_left -= 100
      offset += 100
    end
    record
  end

  def items_response(user = nil, offset = 0)
    RestClient.get items_url(user, offset), { accept: :xml }
  end

  def items_url(user = nil, offset = 0)
    "#{api_url}/almaws/v1/bibs/#{mms_id}#{items_query(user, offset)}#{api_bib_key}"
  end

  def items_query(user = nil, offset = 0)
    "/holdings/ALL/items?limit=100&offset=#{offset}&expand=due_date_policy&user_id=#{api_user_name(user)}&order_by=chron_i&apikey="
  end

  def api_user_name(user)
    if user.blank? || user&.guest
      'GUEST'
    else
      user.uid
    end
  end

  def full_record_url
    "#{api_url}/almaws/v1/bibs/#{mms_id}#{query_inst}#{api_bib_key}"
  end

  def query_inst
    "?view=full&expand=p_avail,e_avail,d_avail,requests&apikey="
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
    request_holding_ids = body.xpath('user_requests/user_request/holding_id').map(&:inner_text)
    request_holding_ids.count(holding_id)
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
    @holding_description = availability.at_xpath('subfield[@code="v"]')&.inner_text
  end

  def items_by_holding_values(holding_id, user = nil)
    items_by_holding_record(holding_id, user).map do |node|
      {
        pid: node.xpath("following-sibling::item_data/pid")&.inner_text,
        barcode: node.xpath("following-sibling::item_data/barcode")&.inner_text,
        type: node.xpath("following-sibling::item_data/physical_material_type").attr("desc")&.value,
        type_code: node.xpath("following-sibling::item_data/physical_material_type")&.text,
        policy: item_policy(node, user),
        description: node.xpath("following-sibling::item_data/description")&.inner_text,
        status: node.xpath('following-sibling::item_data/base_status').attr("desc")&.value,
        temporarily_located: node.xpath('in_temp_location')&.inner_text,
        temp_library: node.xpath('temp_library')&.inner_text,
        temp_location: node.xpath('temp_location')&.inner_text
      }
    end
  end

  def item_policy(node, _user)
    policy_desc = node.xpath('following-sibling::item_data/policy').attr("desc")&.value
    policy_id = node.xpath('following-sibling::item_data/policy')&.inner_text
    due_date_policy = node.xpath('following-sibling::item_data/due_date_policy')&.inner_text
    { policy_desc: policy_desc, policy_id: policy_id, due_date_policy: due_date_policy }
  end

  def physical_holding_hash(availability, user = nil)
    physical_holding_values(availability)
    {
      holding_id: @holding_id,
      library: { label: @library_label, value: @library_code },
      location: { label: @location_label, value: @location_code },
      call_number: @call_number,
      description: @holding_description,
      availability: physical_availability_hash,
      items: items_by_holding_values(@holding_id, user)
    }
  end

  def physical_availability_hash
    {
      copies: @copies,
      available: @available,
      requests: requests(@holding_id),
      availability_phrase: @availability_phrase
    }
  end

  def ave_u_8_present?(availability)
    availability.at_xpath('subfield[@code="u"]').present? && availability.at_xpath('subfield[@code="8"]').present?
  end

  def build_ave_url(portfolio_id)
    "#{alma_openurl_base}/discovery/openurl#{ave_query}#{portfolio_id}"
  end

  def ave_query
    "?institution=#{alma_institution}&vid=#{alma_institution}:blacklight&u.ignore_date_coverage=true&portfolio_pid="
  end
end
