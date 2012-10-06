class SessionsController < ApplicationController
  def create
    oauth = request.env["omniauth.auth"]
  	
  	if current_user
  		auth = current_user.authentications.find_by_provider_and_uid(oauth['provider'], oauth['uid'])
  		if auth
  			auth.data = oauth.to_json.to_s
  			auth.save
  			redirect_to authentications_path, notice: "You already has your #{oauth['provider']} account linked."
  		else
  			current_user.authentications.create!(provider: oauth['provider'], uid: oauth['uid'], data: oauth.to_json.to_s)
				current_user.name = oauth.try(:[],'info').try(:[],'name') || oauth.try(:[],'info').try(:[],'nickname') if current_user.name.blank?
				current_user.email = oauth.try(:[],'info').try(:[],'email') if current_user.email.blank?  			
				current_user.save
  			redirect_to authentications_path, notice: "Your new #{oauth['provider']} account has been linked successfully!"
  		end
  	else
    	authentication = Authentication.find_by_provider_and_uid(oauth['provider'],oauth['uid'])	
			if authentication
				session[:user_id] = user.id
				redirect_to root_url, notice: 'Awwww Yeah! Welcome back!'
			else
				user = User.new
				user.name = oauth.try(:[],'info').try(:[],'name') || oauth.try(:[],'info').try(:[],'nickname') if user.name.blank?
				user.email = oauth.try(:[],'info').try(:[],'email') if user.email.blank?
				if user.save
					user.authentications.create!(provider: oauth['provider'], uid: oauth['uid'], data: oauth.to_json.to_s)
					session[:user_id] = user.id
					redirect_to root_url, notice: 'You are in! Welcome!'
				else
					flash[:error] = user.errors.full_messages
					redirect_to root_url
				end
			end
		end
  end

  def destroy
	  session[:user_id] = nil
	  redirect_to root_url, notice: "See you later!"
  end
end
