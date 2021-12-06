# frozen_string_literal: true
# [Blacklight-overwrite v7.4.1] Adds openurl helper methods for `getit` tab
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def generic_solr_value_to_url(value)
    url_arr = build_arr_links_text_split(values_of_field(value))
    return safe_join(url_arr, tag('br')) if url_arr.present?
    ''
  end

  def multiple_values_new_line(value)
    safe_join(values_of_field(value), tag('br'))
  end

  def multiple_sorted_values_new_line(value)
    safe_join(values_of_field(value)&.map(&:strip)&.uniq&.sort, tag('br'))
  end

  def combine_author_vern(value)
    combined_values =
      (multilined_links_to_facet_flexible(values_of_field(value), 'author_display_ssim') +
        multilined_links_to_facet_flexible(
          value[:document]['author_vern_ssim'], 'author_vern_ssim'
        ))&.compact&.uniq
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

  def multilined_links_to_title_search(value)
    links = build_title_search_links(values_of_field(value), value[:document]['format_ssim'].map { |v| CGI.escape(v) })
    return safe_join(links, tag('br')) if links.present?
    ''
  end

  def availability_present?(doc_avail_values, document)
    doc_avail_values[:physical_exists] &&
      (doc_avail_values[:online_available] || document.url_fulltext.present?)
  end

  def display_bound_with(value)
    parsed_items = values_of_field(value).map { |v| JSON.parse(v) }
    return safe_join(parsed_items.map { |pi| link_to(pi['text'], "/catalog/#{pi['mms_id']}") }, tag('br')) if parsed_items.present?
    ''
  end

  private

  def values_of_field(value)
    value[:document][value[:field]]
  end

  def pull_url_text_from_str(str)
    link_pieces = str.split(' text: ')
    # url first, text second
    [link_pieces.first, (link_pieces.size > 1 ? link_pieces[1] : link_pieces.first)]
  end

  def build_arr_links_text_split(values)
    values.map do |v|
      url, text = pull_url_text_from_str(v)
      tag.a(text, href: url, target: '_blank', rel: 'noopener noreferrer')
    end
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

  def multilined_links_to_facet_flexible(values, field_name)
    ret_vals = values&.map do |v|
      link_to(v, ("/?f%5B#{field_name}%5D%5B%5D=" + CGI.escape(v))).to_s
    end
    return ret_vals if ret_vals.present?
    []
  end

  def build_title_search_links(record_values, record_formats)
    record_values.map do |v|
      query = "/?"
      query += safe_join(record_formats.map { |f| "f%5Bformat_ssim%5D%5B%5D=#{f}" }, "&") if record_formats.present?
      query += record_formats.present? ? "&q=#{CGI.escape(v)}" : "q=#{CGI.escape(v)}"
      query += "&search_field=title"
      link_to v, query
    end
  end
end
