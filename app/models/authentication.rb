class Authentication < ActiveRecord::Base
	belongs_to :user
	attr_accessible :provider, :uid, :data, :oauth_token, :oauth_secret, :oauth_token_expires_at
end
