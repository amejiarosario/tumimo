require 'mongo'
require_relative '../../app/models/data_persistance'
require 'koala'
require_relative '../../app/models/mongo_facebook'

describe MongoFacebook do
	let(:database_name){'facebook_test'}

	def clean_mongo 
		conn = Mongo::Connection.new
		db = conn.db(database_name)
		db.collection_names.each do |collection_name|
			db[collection_name].remove
		end		
	end

	after :all do
		clean_mongo
	end

	before :each do
		clean_mongo
		@access_token = 'AAACEdEose0cBALaHQ0Ot5BeswsnIZBogZA96ZA0A1IGMe0qjcxEuZBJxh1HxeZCNmJ75tAn4wmZCFuK1ZCX1ZCAojuTZArXnUDoQGWBcufJlJOAZDZD' # https://developers.facebook.com/tools/explorer
		@uid = '895685163'
		@mfb = MongoFacebook.new(@uid, @access_token)
		@mfb.data = DataPersistance.new database_name
	end

	context 'user personal info' do
		it 'should get the user information from facebook API' do
			VCR.use_cassette 'facebook/get_object__me' do
				user = @mfb.me
				user['name'].should eq 'Adrian Mejia'
				user['hometown']['name'].should eq "Santo Domingo, Dominican Republic"
				user['location']['name'].should eq "Boston, Massachusetts"
				user['gender'].should eq 'male'
				user['locale'].should eq 'en_US'
			end
		end

		it 'should cache user data after first call' do
			VCR.use_cassette 'facebook/get_object__me' do
				is_cached, data = @mfb.me(true)
				is_cached.should be false

				is_cached, user = @mfb.me(true)
				is_cached.should be true
				user['name'].should eq 'Adrian Mejia'
				user['hometown']['name'].should eq "Santo Domingo, Dominican Republic"
				user['location']['name'].should eq "Boston, Massachusetts"
				user['gender'].should eq 'male'
				user['locale'].should eq 'en_US'
				data.should == user
			end
		end
	end
	context "friends" do
		it "should get friend count from API" 
		it "should have cached the data"
	end
end