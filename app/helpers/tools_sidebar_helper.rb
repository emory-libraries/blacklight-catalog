# frozen_string_literal: true
module ToolsSidebarHelper
  def render_print_in_toolbar
    link_to(t('blacklight.tools.print'), '/#', class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end

  def render_help_in_toolbar
    link_to(t('blacklight.tools.help'), '/#', class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end

  def render_feedback_in_toolbar
    link_to(t('blacklight.tools.feedback'), '/#', class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end
end
