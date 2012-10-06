class OmniauthCallbacksController < Devise::OmniauthCallbacksController
 
  def twitter
    oauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(oauth['provider'],oauth['uid'])
    if authentication
      flash[:notice] = "Welcome back user!"
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create(provider: oauth['provider'], uid: oauth['uid'])
      flash[:notice] = "Your #{oauth['provider']} has been added successfully!"
      redirect_to authentications_url
    else
      user = User.new
      user.authentications.build(provider: oauth['provider'], uid: oauth['uid'])
      if user.save
        flash[:notice] = "You are in! Enjoy your stay!"
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url        
      end
    end

    # current_user.authentications.find_or_create_by_provider_and_uid(oauth['provider'],oauth['uid']) 
    # # TODO: save raw data
    # flash[:notice] = 'Authentication successfully'
    # redirect_to authentications_url    
  end

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
  
  #alias_method :twitter, :all
  #alias_method :facebook, :all
end