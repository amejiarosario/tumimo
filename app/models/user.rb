require 'stalker'

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

	# Process jobs in the background if the data is not already in the database.
	# Return nil if the task is enqueue
	# Return result if the data if data is ready
	def send_job(job = nil, provider = 'facebook', options = {})
		case provider
		when 'facebook'
			options.merge!({oauth1: facebook_oauth.uid, oauth2: facebook_oauth.oauth_token})
			provider_instance = mfb
		when 'twitter'
			options.merge!({oauth1: twitter_oauth.oauth_token, oauth2: twitter_oauth.oauth_secret})
			provider_instance = mtw
		else
			raise "Provider #{provider} not implemented."
			nil
		end
		
		# check if task is ready (is in cache)
		options.merge!({find_and_return: true})
		data = provider_instance.send(job, options)

		if data.nil? #|| (data['metadata']['status'] != 'ready' rescue nil)
			Stalker.enqueue("#{provider.to_s}.#{job.to_s}", options, {ttr: 3600})
			notify
		end

		data
	end

	def notify
		# TODO notify user when his data is ready.... (email, fb-like notification)
	end

	def facebook_oauth
		@facebook_oauth ||= authentications.where(provider: 'facebook').last
	end
	
	def twitter_oauth
		@twitter_oauth ||= authentications.where(provider: 'twitter').last
	end

	def mfb
		unless @mfb
			@mfb = MongoFacebook.new(facebook_oauth.uid, facebook_oauth.oauth_token) #, facebook_oauth.oauth_secret
		end
		@mfb
	end

	def mtw
		unless @mtw
			@mtw = MongoTwitter.new(twitter_oauth.oauth_token, twitter_oauth.oauth_secret)
		end
		@mtw
	end
end
