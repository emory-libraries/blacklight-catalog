# frozen_string_literal: true
require 'citeproc'
require 'csl/styles'
require './lib/citation_string_processor'

class CitationFormatter
  include CitationStringProcessor
  attr_accessor :obj, :default_citations

  def initialize(obj)
    @obj = obj
    @default_citations = {
      "chicago-fullnote-bibliography": chicago_default_citation
    }
  end

  def citation_for(style)
    CiteProc::Processor.new(style: 'chicago-fullnote-bibliography', format: 'html').import(item).render(:bibliography, id: :item).first
  rescue CiteProc::Error, TypeError, ArgumentError
    @default_citations[style.to_sym]
  end

  private

  def item
    CiteProc::Item.new({
                         "id": :item,
                         "archive": nil,
                         "archive_location": nil,
                         "author": obj[:author_ssim]&.join(', '),
                         "collection-title": nil,
                         "dimensions": nil,
                         "edition": obj[:edition_tsim]&.join(', '),
                         "event": nil,
                         "genre": obj[:genre_ssim]&.join(', '),
                         "ISBN": obj[:isbn_ssim]&.join(', '),
                         "ISSN": obj[:issn_ssim]&.join(', '),
                         "issued": obj[:pub_date_isim].first,
                         "publisher": chicago_publisher(obj),
                         "publisher-place": obj[:publisher_location_ssm]&.join(', '),
                         "title": obj[:title_citation_ssi],
                         "type": obj[:format_ssim]&.first&.downcase,
                         "URL": url(obj)
                       })
  end
end
