class User < ActiveRecord::Base
	has_many :authentications, dependent: :destroy
end
