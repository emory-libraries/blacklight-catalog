# frozen_string_literal: true
class OmniauthController < Devise::SessionsController
  def new
    session[:requested_page] = request.referer unless request.referer.present? && URI(request.referer).path == new_user_session_path

    if Rails.env.production?
      redirect_to user_shibboleth_omniauth_authorize_path
    else
      super
    end
  end
end
