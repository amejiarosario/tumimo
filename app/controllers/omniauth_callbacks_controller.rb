class OmniauthCallbacksController < Devise::OmniauthCallbacksController
 
  def facebook
  	# https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview
  	@user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"].except('extra')
      redirect_to new_user_registration_url
    end  	
  end

  def all
    raise request.env["omniauth.auth"].to_yaml
  end
  alias_method :twitter, :all
  #alias_method :facebook, :all
end