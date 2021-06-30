# frozen_string_literal: true
module ToolsSidebarHelper
  def render_print_in_toolbar
    link_to(t('blacklight.tools.print'), '#', onclick: 'javascript:print()', class: 'nav-link')
  end

  def render_help_in_toolbar
    link_to(t('blacklight.tools.help'), '/#', class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end

  def render_feedback_in_toolbar(url)
    link_to(t('blacklight.tools.feedback'),
              "https://emory.libwizard.com/f/blacklight?refer_url=#{url}",
              class: 'nav-link', target: "_blank", rel: 'noopener noreferrer')
  end

  def export_as_ris_solr_document_path(opts = {}, *_)
    solr_document_url(opts[:id], format: :ris) if opts[:id]
  end
end
