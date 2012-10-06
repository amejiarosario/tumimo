class OmniauthCallbacksController < Devise::OmniauthCallbacksController
 
  def all
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
      user.authentications.build(provider: oauth['provider'], uid: oauth['uid'], data: oauth.to_json.to_s)
      #user.email = oauth['info']['email'] if oauth.try(:[],'info').try(:[],'email')
      #user.name = oauth['info']['name'] if oauth.try(:[],'info').try(:[],'name')
      if user.save
        flash[:notice] = "You are in! Enjoy your stay!"
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url        
      end
    end
  end

  def unknown
    raise request.env["omniauth.auth"].to_yaml
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
end