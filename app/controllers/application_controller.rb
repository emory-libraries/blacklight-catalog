# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  protect_from_forgery with: :exception

  before_action do
    Rack::MiniProfiler.authorize_request unless ENV['BLACKLIGHT_BASE_URL'] == 'https://search.libraries.emory.edu'
  end

  def guest_uid_authentication_key(key)
    guest_email_authentication_key(key)
  end

  def require_authenticated_ltds_admin_user
    head :forbidden unless authenticated_ltds_admin_user?
  end

  private

  def authenticated_ltds_admin_user?
    user_signed_in? && current_user.ltds_admin_user?
  end
end
