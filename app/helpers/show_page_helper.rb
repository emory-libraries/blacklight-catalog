# frozen_string_literal: true
module ShowPageHelper
  def vernacular_title_populator(document)
    vern_titles = document['title_vern_display_tesim']&.map&.with_index(1) do |t, i|
      tag.h2(t, class: "vernacular_title_#{i}")
    end

    return safe_join(vern_titles, tag.br) if vern_titles.present?
    ''
  end

  def direct_link(document_id)
    link = solr_document_path(document_id)
    link_text = Rails.env.development? ? 'localhost:3000' : ENV['BLACKLIGHT_BASE_URL'] || ''
    link_text + link
  end

  def colonizer(first_str, second_str)
    return "#{first_str}: #{second_str}" if first_str.present? && second_str.present?
    first_str
  end
end
