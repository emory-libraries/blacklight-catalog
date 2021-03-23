# frozen_string_literal: true

class UrlFulltextPresenter
  attr_reader :solr_document

  def initialize(document:)
    @solr_document = document
  end

  delegate :url_fulltext, to: :solr_document
end
