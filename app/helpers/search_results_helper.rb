# frozen_string_literal: true
module SearchResultsHelper
  def vern_title_search_results_populator(document)
    vern_titles = document['title_vern_display_tesim']&.map&.with_index(1) do |t, i|
      tag.p(t, class: "vern-title-search-results-#{i}")
    end

    return safe_join(vern_titles, tag('br')) if vern_titles.present?
    ''
  end

  # Generates search parameters for eJournals.
  #
  # @param state [Hash] The current search state parameters.
  # @param letter [String, nil] The optional letter to filter by.
  # @return [Hash] The generated search parameters.
  def ejournals_search_params(state:, letter: nil)
    params = state.merge({
                           controller: "catalog",
                           action: "index",
                           search_field: "advanced",
                           commit: "Search",
                           utf8: "✓",
                           sort: "title_ssort asc, pub_date_isim desc"
                         })

    params[:f] = {
      marc_resource_ssim: ["Online"],
      format_ssim: ["Journal, Newspaper or Serial"]
    }

    params[:f] = params[:f].merge({ title_main_first_char_ssim: [letter] }) if letter.present?
    params
  end

  # Generates search parameters for filtering titles that start with a letter.
  #
  # @param state [Hash] The current search state parameters.
  # @param letter [String, nil] The optional letter to filter by.
  # @return [Hash] The generated search parameters.
  def title_starts_with_search_params(state:, letter: nil)
    params = state.merge({ sort: "title_ssort asc, pub_date_isim desc" })

    if params[:f].present?
      if letter.present?
        params[:f] = params[:f].merge({ title_main_first_char_ssim: [letter] })
      else
        params[:f].delete(:title_main_first_char_ssim)
      end
    elsif letter.present?
      params[:f] = { title_main_first_char_ssim: [letter] }
    end

    params
  end

  # Retrieves the first active letter filter from the search state parameters.
  #
  # @param state [Hash] The current state parameters.
  # @return [String, nil] The first active letter, if available.
  def active_letter(state)
    state[:f][:title_main_first_char_ssim]&.first if state[:f]
  end
end
