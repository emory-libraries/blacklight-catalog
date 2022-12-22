# frozen_string_literal: true

xml.instruct! :xml, version: '1.0'
xml.document do
  xml.title @document['title_main_display_ssim']&.first
  xml.author @document['author_display_ssim']&.first
  xml.is_physical_holding @document['marc_resource_ssim']&.include?('At the Library')
  xml.is_electronic_holding @document['marc_resource_ssim']&.include?('Online')
  xml.edition @document['edition_tsim']&.first
  xml.physical_description @document['material_type_display_tesim']&.first
  xml.publisher @document['published_tesim']&.first
  xml.publication_date @document['pub_date_isim']&.first
  xml.isbn @document['isbn_ssim']&.first
  xml.issn @document['issn_ssim']&.first
  xml.supplemental_links do
    @document['url_suppl_ssim']&.each do |supp|
      xml << render(partial: 'supplemental_link', locals: { supp: supp })
    end
  end
  xml.physical_holdings do
    @document.physical_holdings_for_xml&.each do |ph|
      xml << render(partial: 'physical_holding', locals: { ph: ph })
    end
  end
end
