# frozen_string_literal: true

xml.physical_holding do
  xml.call_number ph[:call_number]
  xml.copy_number ph[:availability][:copies]
  xml.library ph[:library][:label]
  xml.location ph[:location][:label]
  xml.items do
    ph[:items]&.each do |i|
      xml.item do
        xml.barcode i[:barcode]
        xml.volume_or_issue i[:description]
        xml.status i[:status]
      end
    end
  end
end
