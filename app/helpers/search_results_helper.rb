# frozen_string_literal: true
module SearchResultsHelper
  def vern_title_search_results_populator(document)
    vern_titles = document['title_vern_display_tesim']&.map&.with_index(1) do |t, i|
      tag.p(t, class: "vern-title-search-results-#{i}")
    end

    return safe_join(vern_titles, tag('br')) if vern_titles.present?
    ''
  end
end
