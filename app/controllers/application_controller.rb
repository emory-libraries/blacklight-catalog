# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  protect_from_forgery with: :exception

  before_action do
    Rack::MiniProfiler.authorize_request if authenticated_ltds_admin_user?
  end

  def guest_uid_authentication_key(key)
    guest_email_authentication_key(key)
  end

  def alma_availability
    document = SolrDocument.find(params[:id])
    availability = AlmaAvailabilityService.new(params[:id])&.current_avail_table_data(document)

    respond_to { |format| format.any { render json: availability } }
  end

  def require_authenticated_ltds_admin_user
    head :forbidden unless authenticated_ltds_admin_user?
  end

  private

  def authenticated_ltds_admin_user?
    user_signed_in? && current_user.ltds_admin_user?
  end
end
