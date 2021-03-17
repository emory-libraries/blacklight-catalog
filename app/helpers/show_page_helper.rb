# frozen_string_literal: true
module ShowPageHelper
  def convert_solr_value_to_url(value)
    links = value[:document][value[:field]].map { |link| tag.a link, { href: link, target: '_blank', rel: 'noopener' } }
    safe_join(links, tag('br'))
  end

  def multiple_values_new_line(value)
    items = value[:document][value[:field]]
    safe_join(items, tag('br'))
  end
end
