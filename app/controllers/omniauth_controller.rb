# frozen_string_literal: true
class OmniauthController < Devise::SessionsController

  def affiliate_login
    
  end

  def do_affiliate_login
    resource = AffiliateUser.new(uid: params[:uid])

    sign_in(resource)
    redirect_to "/"
  end


  def shib_login
      session[:requested_page] = request.referer unless request.referer&.include?('sign_in')
      redirect_to user_shibboleth_omniauth_authorize_path
  end
end
