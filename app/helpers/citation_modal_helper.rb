# frozen_string_literal: true
module CitationModalHelper
  def render_citations(documents)
    return process_mult_documents_citations(documents) if documents.count > 1 && cit_method_respond_test(documents)
    return process_single_document_citations(documents) if cit_method_respond_test(documents)
    ''
  end

  def process_mult_documents_citations(documents)
    mla_cit_arr = documents.inject([]) do |arr, doc|
      arr << tag.div(doc.send(:export_as_mla_citation_txt).html_safe, class: 'citation-text')
    end
    apa_cit_arr = documents.inject([]) do |arr, doc|
      arr << tag.div(doc.send(:export_as_apa_citation_txt).html_safe, class: 'citation-text')
    end

    safe_join(
      [
        tag.h2(t('blacklight.citation.mla'), class: 'citation-header'),
        mla_cit_arr,
        tag.h2(t('blacklight.citation.apa'), class: 'citation-header'),
        apa_cit_arr
      ].flatten, ''
    )
  end

  def process_single_document_citations(documents)
    safe_join(
      [
        tag.h2(t('blacklight.citation.mla'), class: 'citation-header'),
        tag.div(documents.first.send(:export_as_mla_citation_txt).html_safe, class: 'citation-text'),
        tag.h2(t('blacklight.citation.apa'), class: 'citation-header'),
        tag.div(documents.first.send(:export_as_apa_citation_txt).html_safe, class: 'citation-text')
      ].flatten, ''
    )
  end

  def cit_method_respond_test(documents)
    documents.all? { |d| d.respond_to?(:export_as_mla_citation_txt) && d.respond_to?(:export_as_apa_citation_txt) }
  end
end
