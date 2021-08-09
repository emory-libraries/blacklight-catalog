# frozen_string_literal: true

module DocumentDeliveryRequestable
  extend ActiveSupport::Concern

  def doc_delivery_links(phys_holdings, user = nil)
    return [] if user.blank? || user.guest || phys_holdings.blank?
    links = phys_holdings.map do |hol|
      eligible_items = hol[:items].select do |i|
        document_delivery_rules.include?(
          { user_group: user.user_group, library_code: hol[:library][:value], location_code: hol[:location][:value], item_code: i[:type_code] }
        )
      end
      if eligible_items.present?
        { library: hol[:library][:label], location: hol[:location][:label], call_number: hol[:call_number], descriptions: eligible_items.map { |i| i[:description] },
          urls: eligible_items.map { |i| document_delivery_url(hol, i) } }
      end
    end&.compact
    links
  end

  def item_descriptions(item)
    descriptions = []
    descriptions << item[:description]
  end

  def document_delivery_url(holding, item)
    URI::HTTPS.build(host: "illiad.library.emory.edu", path: "/illiad/illiad.dll", query: URI.encode_www_form(doc_del_openurl_hash(holding, item))).to_s
  end

  # TODO: Fix rubocop complaints
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def doc_del_openurl_hash(holding, item)
    {
      "Action": 10,
      "Form": 30,
      "ctx_ver": "Z39.88-2004",
      "rft_val_fmt": "info:ofi/fmt:kev:mtx:#{try(:[], :format_ssim)&.first&.downcase}",
      "rfr_id": "info:sid/primo:#{item[:barcode]}",
      "rft.genre": try(:[], :format_ssim)&.first&.downcase,
      "rft.btitle": try(:[], :title_main_display_ssim)&.first,
      "rft.title": try(:[], :title_main_display_ssim)&.first,
      "rft.au": try(:[], :author_ssim)&.first,
      "rft.date": try(:[], :pub_date_isim)&.first,
      "rft.place": try(:[], :publisher_location_ssim)&.last,
      "rft.pub": try(:[], :published_tesim)&.first,
      "rft.edition": try(:[], :edition_tsim)&.first,
      "rft.isbn": try(:[], :isbn_ssim)&.first,
      "rft.callnumber": try(:[], :local_call_number_tesim)&.first,
      "rft.item_location": holding[:library][:value] + " " + holding[:location][:value],
      "rft.barcode": item[:barcode],
      "rft.doctype": "RB",
      "rft.lib": "EMU",
      "SITE": special_locations_site(holding[:library][:value], holding[:location][:value])
    }
  end
  # rubocop:enable Metrics/MethodLength Metrics/AbcSize
  # rubocop:enable Metrics/AbcSize

  def document_delivery_rules
    DOCUMENT_DELIVERY_RULES
  end

  def one_step_doc_delivery?(phys_holdings, user = nil)
    links = doc_delivery_links(phys_holdings, user)
    check_for_one_step = links.count == 1 && links.first[:urls].size == 1
    @one_step_link = links.first[:urls].first if check_for_one_step
    check_for_one_step
  end

  def two_step_doc_delivery?(phys_holdings, user = nil)
    links = doc_delivery_links(phys_holdings, user)
    check_for_two_step = links.empty? ? false : (links.count > 1 || links.first[:urls].size > 1)
    @two_step_links = links if check_for_two_step
    check_for_two_step
  end

  def one_step_link
    @one_step_link
  end

  def two_step_links
    @two_step_links
  end
end
