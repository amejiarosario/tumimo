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
	
	def mfb
		unless @mfb
			fb_oauth = authentications.where(provider: 'facebook').first
			@mfb = MongoFacebook.new(fb_oauth.uid, fb_oauth.oauth_token, fb_oauth.oauth_secret)
		end
		@mfb
	end

	def mtw
		unless @mtw
			tw_oauth = authentications.where(provider: 'twitter').first
			@mtw = MongoTwitter.new(tw_oauth.oauth_token, tw_oauth.oauth_secret)
		end
		@mtw
	end
end
