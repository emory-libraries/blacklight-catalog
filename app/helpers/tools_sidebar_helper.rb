# frozen_string_literal: true
module ToolsSidebarHelper
  def render_print_in_toolbar
    link_to(t('blacklight.tools.print'), '#', onclick: 'javascript:print()', class: 'nav-link')
  end

  def render_generic_link_in_toolbar(link_text:, link_href:)
    link_to(link_text, link_href, class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end

  def render_link_to_libwizard_in_toolbar(text:, form_name:, url:)
    render_generic_link_in_toolbar(
      link_text: text,
      link_href: "https://emory.libwizard.com/f/#{form_name}?refer_url=#{url}"
    )
  end
end
