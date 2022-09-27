# frozen_string_literal: true
require 'citeproc'
require 'csl/styles'
require './lib/citation_string_processor'

class ChicagoCitationFormatter
  include CitationStringProcessor
  attr_accessor :obj, :default_citations

  def initialize(obj)
    @obj = obj
  end

  def cite!
    CiteProc::Processor.new(style: 'chicago-fullnote-bibliography', format: 'html').import(item).render(:bibliography, id: :item).first
  end

  private

  def item
    CiteProc::Item.new({
                         "id": :item,
                         "author": chicago_author(obj),
                         "issued": obj[:pub_date_isim].first,
                         "publisher": chicago_publisher(obj),
                         "publisher-place": obj[:publisher_location_ssim]&.first,
                         "title": obj[:title_citation_ssi],
                         "type": obj[:format_ssim]&.first&.downcase,
                         "DOI": chicago_doi(obj)
                       })
  end
end
