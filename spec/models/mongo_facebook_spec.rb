require 'mongo'
require_relative '../../app/models/mongo_structure'
require 'koala'
require_relative '../../app/models/mongo_facebook'

describe MongoFacebook do
	context 'user data' do
		it 'should get the user information' do
			access_token = 'AAACEdEose0cBALjeUtfZCdragTzh9vHPtQEF9kDDcbuJKRlwsyvZAFertlC2SO37jTFf0Mx7YqkQ8S0HOr6nmpziHWPULphvQNP84ozQZDZD'
			mfb = MongoFacebook.new(access_token)
			user = mfb.me
			user['name'].should eq 'Adrian Mejia'
			user['gender'].should eq 'male'
			user['locale'].should eq 'en_US'
		end
	end
	context "friends" do
		it "should get friend count from API" 
		it "should have cached the data"
	end
end