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
end
