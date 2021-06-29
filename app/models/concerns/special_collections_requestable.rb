# frozen_string_literal: true
require 'csv'

module SpecialCollectionsRequestable
  extend ActiveSupport::Concern

  def holding_to_request(user = nil)
    @holding_to_request ||= begin
      return false if physical_holdings(user).blank?
      holdings_in_special_collections = physical_holdings(user).map do |holding|
        holding if special_collections_locations.include?({ library_code: holding[:library][:value], location_code: holding[:location][:value] })
      end
      return false if holdings_in_special_collections.compact.empty?
      # TODO: This is a first pass for works that only have one requestable holding
      # More logic should be added here which specific holding should be requested if there are multiple
      holdings_in_special_collections.compact&.first
    end
  end

  def special_collections_url(user = nil)
    URI::HTTPS.build(host: "aeon.library.emory.edu", path: "/aeon/aeon.dll", query: URI.encode_www_form(openurl_hash(user))).to_s
  end

  # TODO: Fix rubocop complaints
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def openurl_hash(user = nil)
    {
      "Action": 10,
      "Form": 30,
      "ctx_ver": "Z39.88-2004",
      "rft_val_fmt": "info:ofi/fmt:kev:mtx:#{try(:[], :format_ssim)&.first&.downcase}",
      "rfr_id": "info:sid/primo:#{holding_to_request(user)[:items_by_holding].first[:barcode]}",
      "rft.genre": try(:[], :format_ssim)&.first&.downcase,
      "rft.btitle": try(:[], :title_main_display_tesim)&.first,
      "rft.title": try(:[], :title_main_display_tesim)&.first,
      "rft.au": try(:[], :author_ssim)&.first,
      "rft.date": try(:[], :pub_date_isim)&.first,
      "rft.place": try(:[], :publisher_location_ssim)&.last,
      "rft.pub": try(:[], :published_tesim)&.first,
      "rft.edition": try(:[], :edition_tsim)&.first,
      "rft.isbn": try(:[], :isbn_ssim)&.first,
      "rft.callnumber": try(:[], :local_call_number_tesim)&.first,
      "rft.item_location": holding_to_request(user)[:library][:value] + " " + holding_to_request(user)[:location][:value],
      "rft.barcode": holding_to_request(user)[:items_by_holding].first[:barcode],
      "rft.doctype": "RB",
      "rft.lib": "EMU",
      "SITE": special_locations_site(holding_to_request(user)[:library][:value], holding_to_request(user)[:location][:value])
    }
  end
  # rubocop:enable Metrics/MethodLength Metrics/AbcSize
  # rubocop:enable Metrics/AbcSize

  def special_locations_site(library_code, location_code)
    case library_code
    when "THEO"
      "THEOLOGYEU"
    when "HLTH"
      "HEALTHEU"
    when "OXFD"
      "OXFORDEU"
    when "LSC"
      special_locations_site_by_location(location_code)
    when "MARBL"
      "MARBLEU"
    end
  end

  def special_locations_site_by_location(location_code)
    if location_code == "TSTORNC"
      "THEOLOGYEU"
    else
      "MARBLEU"
    end
  end

  # TODO: Turn this into configuration from csv file, as output by Alma
  def special_collections_locations
    @special_collections_locations ||= begin
      path = Rails.root.join("config", "special_collections_locations.csv")
      file = File.read(path)
      CSV.parse(file, headers: true).map do |row|
        { library_code: row["Library Code (Active)"], location_code: row["Location Code"] }
      end
    end
  end
end
