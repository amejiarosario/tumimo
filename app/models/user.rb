class User < ActiveRecord::Base
	has_many :authentications, dependent: :destroy
	
	def add_authentication(oauth)
		authentications.create!(
			provider: oauth['provider'], 
			uid: oauth['uid'], 
			oauth_token: oauth['credentials']['token'],
			oauth_token_at: Time.at(oauth.try(:[],'credentials').try(:[],'expires_at')),
			data: oauth.to_json.to_s
		)
	end
end
