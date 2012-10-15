class User < ActiveRecord::Base
	has_many :authentications, dependent: :destroy
	
	def create_authentication(oauth)
		authentications.create!(
			provider: oauth['provider'], 
			uid: oauth['uid'], 
			oauth_token: oauth['credentials']['token'],
			oauth_secret: oauth['credentials'].try(:[],'secret'),
			oauth_token_expires_at: oauth['credentials'].try(:[],'expires_at') ? Time.at(oauth['credentials'].try(:[],'expires_at')) : nil,
			data: oauth.to_json.to_s
		)
	end
	
	def facebook
		unless @facebook
			fb_oauth = authentications.where(provider: 'facebook').first
			@facebook = MongoFacebook.new(fb_oauth.oauth_token, fb_oauth.oauth_secret)
		end
		@facebook
	end

	def twitter
		unless @twitter
			tw_oauth = authentications.where(provider: 'twitter').first
			@twitter = MongoTwitter.new(tw_oauth.oauth_token, tw_oauth.oauth_secret)
		end
		@twitter
	end
end
