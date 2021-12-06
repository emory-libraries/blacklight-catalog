# frozen_string_literal: true
module SearchResultsHelper
  def vern_title_search_results_populator(document)
    vern_titles = document['title_vern_display_tesim']&.map&.with_index(1) do |t, i|
      tag.p(t, class: "vern-title-search-results-#{i}")
    end

    return safe_join(vern_titles, tag('br')) if vern_titles.present?
    ''
  end

  def first_char_search_state(search_state)
    search_state.to_h.merge('sort': 'title_ssort asc, pub_date_isim desc')
  end

  def first_char_search_state_ejournals(search_state)
    search_state.to_h['controller'] = 'catalog'
    search_state.to_h['action'] = 'index'
    search_state.to_h.merge('search_field': 'advanced', 'commit': 'Search', 'utf8': '✓', 'sort': 'title_ssort asc, pub_date_isim desc')
  end

  def first_char_active_letter(state)
    state['f']['title_main_first_char_ssim']&.first if state['f']
  end

  def first_char_letter_hash(state, letter)
    letter_state = state.dup
    letter_state['f'] = processed_facet(letter_state, letter)
    letter_state
  end

  def first_char_letter_hash_ejournals(state, letter)
    letter_state = state.dup
    letter_state['f'] = processed_facet_ejournals(letter_state, letter)
    letter_state
  end

  def first_char_cleared_hash(state)
    state['f']&.delete('title_main_first_char_ssim')
    state
  end

  def processed_facet(letter_state, letter)
    return letter_state['f'].merge('title_main_first_char_ssim': [letter]) if letter_state['f'].present?
    { 'title_main_first_char_ssim': [letter] }
  end

  def processed_facet_ejournals(letter_state, letter)
    return letter_state['f'].merge('title_main_first_char_ssim': [letter]) if letter_state['f'].present?
    { 'title_main_first_char_ssim': [letter], 'marc_resource_ssim': ["Online"], 'format_ssim': ["Journal, Newspaper or Serial"] }
  end
end
