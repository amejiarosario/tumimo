class User < ActiveRecord::Base
	has_many :authentications, dependent: :destroy
	DATA = "uid, name, first_name, last_name, affiliations, timezone, birthday_date, birthday, devices, sex, hometown_location, relationship_status, significant_other_id, current_location, work, education, languages, likes_count, wall_count, friend_count, mutual_friend_count"
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
			oauth_token = authentications.where(provider: 'facebook').first.oauth_token
			@facebook = Koala::Facebook::API.new(oauth_token)
		end
		@facebook
	end

	def facebook_friends
		@fb_friends ||= facebook.get_connections('me', 'friends')
	end

	# FIXME: run in the background, takes couple of minutes to finish
	def facebook_friends_data(data=DATA)
		unless @fb_friends_data
			ids = facebook_friends.map { |e| e['id'] }.join(', ')
			@fb_friends_data = facebook.fql_query("select #{data} from user where uid in (#{ids})")
		end
	end

	def twitter
		unless @twitter
			Twitter.configure do |config|
			  config.consumer_key = ENV['TUMIMO_TWITTER_KEY']
			  config.consumer_secret = ENV['TUMIMO_TWITTER_SECRET']
			end
			tw_oauth = authentications.where(provider: 'twitter').first
			@twitter = Twitter::Client.new(
			  :oauth_token => tw_oauth.oauth_token,
			  :oauth_token_secret => tw_oauth.oauth_secret
			)
		end
		@twitter
	end
end
