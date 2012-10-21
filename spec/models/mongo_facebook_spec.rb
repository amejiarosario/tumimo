require 'mongo'
require_relative '../../app/models/mongo_structure'
require 'koala'
require_relative '../../app/models/mongo_facebook'

describe MongoFacebook do
	context 'user data' do
		
		it 'should get the user information' do
			VCR.use_cassette 'facebook/get_object__me' do
				access_token = 'AAACEdEose0cBALaHQ0Ot5BeswsnIZBogZA96ZA0A1IGMe0qjcxEuZBJxh1HxeZCNmJ75tAn4wmZCFuK1ZCX1ZCAojuTZArXnUDoQGWBcufJlJOAZDZD' # https://developers.facebook.com/tools/explorer
				mfb = MongoFacebook.new(access_token)
				user = mfb.me
				user['name'].should eq 'Adrian Mejia'
				user['gender'].should eq 'male'
				user['locale'].should eq 'en_US'
			end
		end
	end
	context "friends" do
		it "should get friend count from API" 
		it "should have cached the data"
	end
end