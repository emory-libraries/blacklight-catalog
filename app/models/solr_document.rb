# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display_tesi
  extension_parameters[:marc_format_type] = :marcxml
  use_extension(Blacklight::Solr::Document::Marc) do |document|
    document.key?(SolrDocument.extension_parameters[:marc_source_field])
  end

  field_semantics.merge!(
    title: "title_tesim",
    author: "author_ssm",
    language: "language_ssim",
    format: "format_tesim"
  )

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def combined_author_display_vern
    ret_array = []
    self['author_display_ssim'].each { |v| ret_array << v } if self['author_display_ssim'].present?
    self['author_vern_ssim'].each { |v| ret_array << v } if self['author_vern_ssim'].present?
    ret_array.uniq
  end

  def url_fulltext
    self['url_fulltext_ssm']
  end

  def more_options
    self['format_ssim']
  end

  def api_url
    ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  end

  def api_key
    ENV.fetch('ALMA_BIB_KEY')
  end

  # Documentation for availability field from Alma
  # https://knowledge.exlibrisgroup.com/Primo/Knowledge_Articles/What_does_each_subfield_in_the_AVA_tag_hold_when_records_are_extracted_from_Voyager_for_Primo%3F
  def body
    url = "#{api_url}/almaws/v1/bibs/#{id}#{query_inst}#{api_key}"
    response = RestClient.get url, { accept: :xml }
    Nokogiri::XML(response)
  end

  def raw_availability
    body.xpath('bib/record/datafield[@tag="AVA"]')
  end

  def query_inst
    "?view=full&expand=p_avail,e_avail,d_avail,requests&apikey="
  end

  def requests?
    body.xpath("bib/requests").inner_text.to_i.positive?
  end

  def requests(holding_id)
    if requests? == false
      0
    else
      retrieve_requests(holding_id)
    end
  end

  def retrieve_requests(holding_id)
    base_requests_link = body.at_xpath('bib/requests').attributes["link"].value
    url = base_requests_link + "?status=active&apikey=#{api_key}"
    response = RestClient.get url, { accept: :xml }
    body = Nokogiri::XML(response)
    request_holding_id = body.at_xpath('user_requests/user_request/holding_id').inner_text
    if holding_id == request_holding_id
      1
    else
      0
    end
  end

  def item_hash(availability)
    copies = availability.at_xpath('subfield[@code="f"]').inner_text.to_i
    unavailable = availability.at_xpath('subfield[@code="g"]').inner_text.to_i
    available = copies - unavailable
    holding_id = availability.at_xpath('subfield[@code="8"]').inner_text
    {
      library: availability.at_xpath('subfield[@code="q"]').inner_text,
      location: availability.at_xpath('subfield[@code="c"]').inner_text,
      call_number: availability.at_xpath('subfield[@code="d"]').inner_text,
      availability: {
        copies: copies,
        available: available,
        requests: requests(holding_id)
      }
    }
  end

  def holdings
    holdings_object = []
    raw_availability.map do |availability|
      holdings_object << item_hash(availability)
    end
    holdings_object
  end
end
