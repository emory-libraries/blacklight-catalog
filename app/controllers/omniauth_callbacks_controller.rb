# frozen_string_literal: true
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      set_flash_message :notice, :success, kind: "Emory"
      sign_in @user
      redirect_to session[:requested_page] || request.env["omniauth.origin"] || root_path
    else
      redirect_to root_path
      set_flash_message(:notice, :failure, kind: "Emory", reason: "you aren't authorized to use this application.")
    end
  end
end
