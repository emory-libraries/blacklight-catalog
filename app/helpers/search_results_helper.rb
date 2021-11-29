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

  def render_physical_avail_spans(avail_values, service_page_link)
    return unless avail_values[:physical_exists]
    status = get_phys_avail_status(avail_values)
    label = phys_label_span(status)
    service_page_anchor = serv_page_anch(status, service_page_link)
    dt = tag.span(service_page_anchor, class: "phys-avail-button")

    safe_join([label, dt])
  end

  def phys_label_span(status)
    avail_class = get_avail_class(status)
    tag.span(status, class: "btn rounded-0 mb-2 phys-avail-label #{avail_class}")
  end

  def serv_page_anch(status, service_page_link)
    tag.a("#{'LOCATE/' unless status == 'Not Available'}REQUEST",
           href: service_page_link, target: '_blank', rel: 'noopener noreferrer',
           class: 'btn btn-md rounded-0 mb-2 btn-outline-primary avail-link-el')
  end

  def render_online_link_span(mms_id)
    tag.span(online_modal_link(mms_id), class: "online-avail-button")
  end

  def online_modal_link(mms_id)
    tag.a("CONNECT", href: "#", data: { toggle: 'modal', target: "#avail-modal-#{mms_id}" }, class: "btn btn-md rounded-0 mb-2 btn-outline-primary avail-link-el")
  end

  def processed_facet(letter_state, letter)
    return letter_state['f'].merge('title_main_first_char_ssim': [letter]) if letter_state['f'].present?
    { 'title_main_first_char_ssim': [letter] }
  end

  def processed_facet_ejournals(letter_state, letter)
    return letter_state['f'].merge('title_main_first_char_ssim': [letter]) if letter_state['f'].present?
    { 'title_main_first_char_ssim': [letter], 'marc_resource_ssim': ["Online"], 'format_ssim': ["Journal, Newspaper or Serial"] }
  end

  def get_phys_avail_status(avail_values)
    if avail_values[:physical_check_holdings]
      'Check Holdings'
    elsif avail_values[:physical_available]
      'Available'
    else
      'Not Available'
    end
  end

  def get_avail_class(status)
    case status
    when "Check Holdings"
      'avail-unknown'
    when "Available"
      'avail-success'
    else
      'avail-danger'
    end
  end
end
