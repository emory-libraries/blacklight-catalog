# frozen_string_literal: true

if ph[:items].size.positive?
  xml.physical_holding do
    xml.call_number ph[:call_number]
    xml.items do
      ph[:items]&.each do |i|
        xml.item do
          xml.library ActiveModel::Type::Boolean.new.cast(i[:temporarily_located]) ? i[:temp_library] : ph[:library][:value]
          xml.location ActiveModel::Type::Boolean.new.cast(i[:temporarily_located]) ? i[:temp_location] : ph[:location][:value]
          xml.barcode i[:barcode]
          xml.volume_or_issue i[:description]
          xml.status i[:status]
        end
      end
    end
  end
end
