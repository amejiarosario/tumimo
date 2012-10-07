class Authentication < ActiveRecord::Base
	belongs_to :user
	attr_accessible :provider, :uid, :data, :oauth_token, :oauth_token_at
end
