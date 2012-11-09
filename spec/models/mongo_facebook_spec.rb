require 'vcr_helper'
require 'mongo'
require_relative '../../app/models/data_persistance'
require 'koala'
require_relative '../../app/models/mongo_facebook'

describe MongoFacebook do
	let(:database_name){'facebook_test'}
	let(:access_token){'AAAFNKZCBGXpABAHQoMDIdLOABlzr4f8KHzUNXDTga0m9MfXEsVnM1gATNNsbcQpX7iFzrSIVC64ChO9ZAMDheowcGxyzRAPHrRNtU65AZDZD'}
  let(:uid){'895685163'}
  let(:mfb){ MongoFacebook.new(uid, access_token) }
  
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
		# VCR.use_cassette 'facebook/adrian_user' do
			@mfb = MongoFacebook.new(uid, access_token)
			@mfb.data = DataPersistance.new database_name
		# end
	end

	context 'user personal info' do
		it 'should get the user information from facebook API' do
			VCR.use_cassette 'facebook/get_object__me', :record => :new_episodes do
				user = @mfb.me['data']['raw']
				#user['metadata']['data_type'].should == 'raw'
				user['name'].should eq 'Adrian Mejia'
				user['hometown']['name'].should eq "Santo Domingo, Dominican Republic"
				user['location']['name'].should eq "Boston, Massachusetts"
				user['gender'].should eq 'male'
				user['locale'].should eq 'en_US'
			end
		end

		it 'should cache user data after first call' do
			VCR.use_cassette 'facebook/get_object__me', :record => :new_episodes do
				is_cached, data = @mfb.me(true)
				is_cached.should be false				
				is_cached, user = @mfb.me(true)
				is_cached.should be true
				user['metadata']['data_type'].should == 'raw'
				user = user['data']['raw']
				user['name'].should eq 'Adrian Mejia'
				user['hometown']['name'].should eq "Santo Domingo, Dominican Republic"
				user['location']['name'].should eq "Boston, Massachusetts"
				user['gender'].should eq 'male'
				user['locale'].should eq 'en_US'
				data['data']['raw'].should == user
			end
		end
	end

	context 'feeds and wall posts' do
		it 'gets post recursively' do
			VCR.use_cassette 'facebook/get_connections__me_feed', :record => :new_episodes do
				data = @mfb.feed
				#puts "**** raw = #{data.inspect}"
				puts "*** next_page = #{data['data']['next_page']}"
				data['metadata']['data_type'].should == 'feed'
				data['data']['next_page'].should be_empty
				data['data']['raw'].count.should be 6513
			end
		end
	end

	context "friends" do
		it "should get friend count from API" do
			VCR.use_cassette 'facebook/get_connections__me_friends_1605', :record => :new_episodes do
				is_cached, friend_ids = @mfb.friend_ids(true)
				friend_ids['metadata']['data_type'].should == 'raw' # FIXME diff
				friend_ids = friend_ids['data']['raw']
				friend_ids.count.should be 1605
				friend_ids.select{|t| t['name'] =~ /Esther\ Brown/}.count.should be 1
				# test cache
				is_cached.should be false
				is_cached, cache = @mfb.friend_ids(true)
				is_cached.should be true
				cache['data']['raw'].should == friend_ids
			end
		end
		# context 'friends history' do
		# 	before :each do
		# 		# VCR.use_cassette 'facebook/test_user' do
		# 			@access_token2 = 'AAAFNKZCBGXpABAL5ZAzSk0J6tgZANXNedBnt92CZB3CDNmANIunYg8Tk3cgo6CKZCFXVMgSZCtoy8qroDI9cNvZA5J0uO97agE1b2XMLWnnfUekyro4xbnW' # https://developers.facebook.com/tools/explorer
		# 			@uid2 = '100004553863831'
		# 			@mfb2 = MongoFacebook.new(@uid2, @access_token2)
		# 			@mfb2.data = DataPersistance.new database_name				
		# 		# end
		# 		VCR.use_cassette 'facebook/get_connections__me_friends_7' do
		# 			is_cached, friends = @mfb2.friend_ids(true, 0)
		# 			is_cached.should be false
		# 			friends.count.should be 7
		# 		end					
		# 	end

		# 	it "detect when new friends :) " do
		# 		VCR.use_cassette('facebook/get_connections__me_friends_9') do
		# 			is_cached, friends = @mfb2.friend_ids(true, 0)
		# 			is_cached.should be false
		# 			friends.count.should be 9
		# 		end				
		# 	end

		# 	it "detects when friends unfriend :( " do
		# 		VCR.use_cassette('facebook/get_connections__me_friends_8') do
		# 			is_cached, friends = @mfb2.friend_ids(true, 0)
		# 			is_cached.should be false
		# 			friends.count.should be 8
		# 		end								
		# 	end
		# end
	end
end