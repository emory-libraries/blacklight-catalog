# frozen_string_literal: true

xml.instruct! :xml, version: '1.0'
xml.document do
  xml.title @document['title_main_display_ssim']&.first
  xml.author @document['author_display_ssim']&.first
  xml.edition @document['edition_tsim']&.first
  xml.publisher @document['published_tesim']&.first
  xml.publication_date @document['pub_date_isim']&.first
  xml.isbn @document['isbn_ssim']&.first
  xml.issn @document['issn_ssim']&.first
  xml.holdings do
    @document.physical_holdings&.each do |ph|
      xml.holding do
        xml.barcodes(ph[:items].map { |i| i[:barcode] }.join('|'), { type: 'multi-value', delim: '|' })
        xml.volumes_issues(ph[:items].map { |i| i[:description] }.join('|'), { type: 'multi-value', delim: '|' })
        xml.call_number ph[:call_number]
        xml.copy_number ph[:availability][:copies]
        xml.library ph[:library][:label]
        xml.location ph[:location][:label]
      end
    end
  end
end
