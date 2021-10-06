# frozen_string_literal: true
class OmniauthController < Devise::SessionsController
  def new
    session[:requested_page] = request.referer&.include?('sign_in') ? root_path : request.referer
    if Rails.env.production?
      redirect_to user_shibboleth_omniauth_authorize_path
    else
      super
    end
  end
end
