require 'vcr_helper'
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
		@access_token = 'AAACEdEose0cBAJuDHyZBBQ6IiF96pQurvzXbHQvhKbc41I6kRUsG9O2j4Qv0B9MBZCFBHJj2ZCIX7GCPnmZADpvQhPzKizU7Kqs5gXUMEgZDZD' # https://developers.facebook.com/tools/explorer
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
		it "should get friend count from API" do
			VCR.use_cassette 'facebook/get_connections__me_friends_1583' do
				friend_ids = @mfb.friend_ids
				friend_ids.count.should be 1583
				friend_ids.select{|t| t['name'] =~ /Esther\ Brown/}.count.should be 1
				# test cache
				is_cached, cache = @mfb.friend_ids(true)
				is_cached.should be true
				cache.should == friend_ids
			end
		end
		context 'friends history' do
			before :each do
				# VCR.use_cassette 'facebook/test_user' do
					@access_token2 = 'AAAFNKZCBGXpABAL5ZAzSk0J6tgZANXNedBnt92CZB3CDNmANIunYg8Tk3cgo6CKZCFXVMgSZCtoy8qroDI9cNvZA5J0uO97agE1b2XMLWnnfUekyro4xbnW' # https://developers.facebook.com/tools/explorer
					@uid2 = '100004553863831'
					@mfb2 = MongoFacebook.new(@uid2, @access_token2)
					@mfb2.data = DataPersistance.new database_name				
				# end
				VCR.use_cassette 'facebook/get_connections__me_friends_7' do
					is_cached, friends = @mfb2.friend_ids(true, 0)
					is_cached.should be false
					friends.count.should be 7
				end					
			end

			it "detect when new friends :) " do
				VCR.use_cassette('facebook/get_connections__me_friends_9') do
					is_cached, friends = @mfb2.friend_ids(true, 0)
					is_cached.should be false
					friends.count.should be 9
				end				
			end

			it "detects when friends unfriend :( " do
				VCR.use_cassette('facebook/get_connections__me_friends_8') do
					is_cached, friends = @mfb2.friend_ids(true, 0)
					is_cached.should be false
					friends.count.should be 8
				end								
			end
		end
	end
end