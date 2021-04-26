# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  protect_from_forgery with: :exception

  def guest_uid_authentication_key(key)
    guest_email_authentication_key(key)
  end

  def alma_availability
    document = SolrDocument.find(params[:id])
    availability = AlmaAvailabilityService.new(params[:id])&.current_avail_table_data(document)

    respond_to { |format| format.any { render json: availability } }
  end
end
