# frozen_string_literal: true
require 'csv'
module Statusable
  extend ActiveSupport::Concern

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
    special_collections_location_for_holding(user).present?
  end

  def special_collections_location_for_holding(user = nil)
    return false if physical_holdings(user).blank?
    holding_locations = physical_holdings(user).map { |holding| { library_code: holding[:library][:value], location_code: holding[:location][:value] } }
    common_locations = holding_locations & special_collections_locations
    return false if common_locations.empty?
    common_locations
  end

  def special_collections_url(user = nil)
    URI::HTTPS.build(host: "aeon.library.emory.edu", path: "/aeon/aeon.dll", query: URI.encode_www_form(openurl_hash(user))).to_s
  end

  # TODO: This should be the barcode of the item being requested
  def barcode_for_request(user = nil)
    "010001072974"
  end

  # rubocop:disable Metrics/MethodLength
  def openurl_hash(user = nil)
    {
      "Action": 10,
      "Form": 30,
      "ctx_ver": "Z39.88-2004",
      "rft_val_fmt": "info:ofi/fmt:kev:mtx:#{first_or_nil('format_ssim')&.downcase}",
      "rfr_id": "info:sid/primo:#{barcode_for_request(user)}",
      "rft.genre": first_or_nil("format_ssim")&.downcase,
      "rft.btitle": first_or_nil("title_main_display_tesim"),
      "rft.title": first_or_nil("title_main_display_tesim"),
      "rft.au": first_or_nil("author_ssim"),
      "rft.date": first_or_nil("pub_date_isim"),
      "rft.place": human_readable_pub_location,
      "rft.pub": first_or_nil("published_tesim"),
      "rft.edition": first_or_nil("edition_tsim"),
      "rft.isbn": first_or_nil("isbn_ssim"),
      "rft.callnumber": first_or_nil("local_call_number_tesim"),
      "rft.item_location": special_collections_location_for_holding(user).first[:library_code] + " " + special_collections_location_for_holding(user).first[:location_code],
      "rft.barcode": barcode_for_request(user),
      "rft.doctype": "RB",
      # TODO: Determine the source for this code and fill in as appropriate / needed
      "rft.lib": "EMU",
      "SITE": special_locations_site(special_collections_location_for_holding(user).first[:library_code])
    }
  end
  # rubocop:enable Metrics/MethodLength

  def special_locations_site(library_code)
    case library_code
    when "THEO"
      "THEOLOGYEU"
    when "HLTH"
      "HEALTHEU"
    when "OXFD"
      "OXFORDEU"
    when "LAW"
      "LAWEU"
    when "MARBL"
      "MARBLEU"
    end
  end

  def first_or_nil(key)
    try(:[], key.to_sym)&.first
  end

  def human_readable_pub_location
    try(:[], :publisher_location_ssim)&.last
  end

  def special_collections_locations
    [{ library_code: "LAW", location_code: "SPCOL" }, { library_code: "LAW", location_code: "SPCOV" }, { library_code: "LAW", location_code: "SPDIS" },
     { library_code: "LAW", location_code: "SPISO" }, { library_code: "LSC", location_code: "RSTORDX" }, { library_code: "LSC", location_code: "RSTORM" },
     { library_code: "LSC", location_code: "RSTORR" }, { library_code: "OXFD", location_code: "SPCOL" }, { library_code: "THEO", location_code: "SPCOL" },
     { library_code: "THEO", location_code: "SPDOZ" }, { library_code: "THEO", location_code: "SPOZ" }, { library_code: "THEO", location_code: "SPPAM" },
     { library_code: "THEO", location_code: "SPREF" }, { library_code: "THEO", location_code: "SPRES" }, { library_code: "MARBL", location_code: "MAP" },
     { library_code: "MARBL", location_code: "MEDIA" }, { library_code: "MARBL", location_code: "MSSTK" }, { library_code: "MARBL", location_code: "REF" },
     { library_code: "MARBL", location_code: "SPOZ" }, { library_code: "MARBL", location_code: "STACK" }, { library_code: "MARBL", location_code: "STAFF" },
     { library_code: "MARBL", location_code: "UNASSIGNED" }, { library_code: "MARBL", location_code: "VAUL2" }, { library_code: "HLTH", location_code: "SPCOL" }]
  end

  def due_date_policies(user = nil)
    physical_holdings(user).map do |holding|
      holding[:items_by_holding].map do |item|
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

  def item_policy(node, _user)
    policy_desc = node.xpath('policy').attr("desc")&.value
    policy_id = node.xpath('policy')&.inner_text
    due_date_policy = node.xpath('due_date_policy')&.inner_text
    { policy_desc: policy_desc, policy_id: policy_id, due_date_policy: due_date_policy }
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
