# frozen_string_literal: true
module ShowPageHelper
  def convert_solr_value_to_url(value)
    links = value[:document][value[:field]].map do |link|
      tag.a link, { href: link, target: '_blank', rel: 'noopener noreferrer' }
    end
    safe_join(links, tag('br'))
  end

  def multiple_values_new_line(value)
    items = value[:document][value[:field]]
    safe_join(items, tag('br'))
  end

  def vernacular_title_populator(document)
    vern_titles = document['title_vern_display_tesim']&.map&.with_index(1) do |t, i|
      tag.h2(t, class: "vernacular_title_#{i}")
    end

    return safe_join(vern_titles, tag('br')) if vern_titles.present?
    ''
  end

  def combine_author_vern(value)
    combined_values = value[:document].combined_author_display_vern
    return safe_join(combined_values, tag('br')) if combined_values.present?
    ''
  end

  def multilined_links_to_facet(value)
    field = value[:field]
    ret_vals = value[:values].map { |v| link_to v, "/?f%5B#{field}%5D%5B%5D=" + CGI.escape(v) } if value[:values].present?
    return safe_join(ret_vals, tag('br')) if ret_vals.present?
    ''
  end
end
