# frozen_string_literal: true
module ToolsSidebarHelper
  def render_print_in_toolbar
    link_to(t('blacklight.tools.print'), '#', onclick: 'javascript:print()', class: 'nav-link')
  end

  def render_help_in_toolbar
    link_to(t('blacklight.tools.help'), 'https://search.libraries.emory.edu/help', class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end

  def render_feedback_in_toolbar(url)
    link_to(t('blacklight.tools.feedback'),
              "https://emory.libwizard.com/f/blacklight?refer_url=#{url}",
              class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end
end
