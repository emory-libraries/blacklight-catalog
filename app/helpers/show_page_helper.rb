# frozen_string_literal: true
module ShowPageHelper
  def generic_solr_value_to_url(value)
    url_arr = build_arr_links_text_split(values_of_field(value))
    return safe_join(url_arr, tag('br')) if url_arr.present?
    ''
  end

  def build_arr_links_text_split(values)
    values.map do |v|
      url, text = pull_url_text_from_str(v)
      tag.a(text, href: url, target: '_blank', rel: 'noopener noreferrer')
    end
  end

  def pull_url_text_from_str(str)
    link_pieces = str.split(' text: ')
    # url first, text second
    [link_pieces.first, (link_pieces.size > 1 ? link_pieces[1] : link_pieces.first)]
  end

  def multiple_values_new_line(value)
    safe_join(values_of_field(value), tag('br'))
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
    ret_vals = value[:values].uniq.map { |v| link_to v, "/?f%5B#{field}%5D%5B%5D=" + CGI.escape(v) } if value[:values].present?
    return safe_join(ret_vals, tag('br')) if ret_vals.present?
    ''
  end

  def author_additional_format(value)
    ret_str = nil
    if value[:values].size <= 5
      ret_str = multilined_links_to_facet_author_addl(value[:values])
    else
      build_arr = [multilined_links_to_facet_author_addl(value[:values].first(5))]
      build_arr.push(
        author_additional_collapse_span(
          multilined_links_to_facet_author_addl(value[:values][5..(value[:values].size - 1)])
        )
      )
      build_arr.push(author_additional_collapse_link)
      ret_str = safe_join(build_arr, tag('br'))
    end
    ret_str
  end

  def author_additional_collapse_link
    link_to('',
          '#extended-author-addl',
          class: 'btn btn-link additional-authors-collapse collapsed',
          data: { toggle: 'collapse' },
          role: "button",
          'aria-expanded' => "false",
          'aria-controls' => "extended-author-addl")
  end

  def author_additional_collapse_span(values)
    tag.span(values, id: 'extended-author-addl', class: 'collapse collapsible-addl-authors')
  end

  def multilined_links_to_facet_author_addl(values)
    ret_vals = values.map do |v|
      line_pieces = v.split(' relator: ')
      quer_disp = line_pieces[0]
      relator = line_pieces.size == 2 ? line_pieces[1] : nil

      ret_line = link_to(quer_disp, ("/?f%5Bauthor_addl_ssim%5D%5B%5D=" + CGI.escape(quer_disp))).to_s
      ret_line += ", #{relator}" if relator.present?
      ret_line
    end
    return safe_join(ret_vals, tag('br')) if ret_vals.present?
    ''
  end

  def values_of_field(value)
    value[:document][value[:field]]
  end

  def direct_link(document_id)
    link = solr_document_path(document_id)
    link_to('Direct Link', link, class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end
end
