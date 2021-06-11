class SessionsController < Devise::SessionsController
  def create
    if AlmaVerificationService.new(params['user']['uid'], params['user']['password']).verified?
      @user = User.from_affiliate(params['user']['uid'])
      if @user.persisted?
        set_flash_message(:notice, :signed_in)
        sign_in @user
        redirect_to session[:requested_page] || root_path
      else
        set_flash_message(:notice, :failure, reason: "A system error has occured.")
        redirect_to root_path
      end
    else
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      if !session[:return_to].blank?
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        respond_with resource, :location => after_sign_in_path_for(resource)
      end
    end
  end
end
