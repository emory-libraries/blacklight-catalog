# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  # include Blacklight::Solr::Document::Marc
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

  # used by blacklight_alma
  def alma_mms_id
    fetch('id', nil)
  end

  # returns an array of IDs to query through API to get holdings
  # for this document. This is usually just the alma MMS ID for
  # this bib record, but in the case of boundwith records, we return
  # the boundwith IDs, because that's where Alma stores the holdings.
  def alma_availability_mms_ids
    fetch('bound_with_ids', [alma_mms_id])
  end
end
