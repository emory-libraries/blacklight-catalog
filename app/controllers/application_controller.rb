# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  protect_from_forgery with: :exception

  def guest_uid_authentication_key(key)
    guest_email_authentication_key(key)
  end

  def require_flipflop_access_privileges
    head :forbidden unless can? :manage, :flipflop
  end
end
