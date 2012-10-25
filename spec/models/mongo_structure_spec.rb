require 'vcr_helper'
require 'mongo'
require_relative '../../app/models/data_persistance'

describe DataPersistance do
	let(:database_name){'data_persistance_test'}

	before :all do
		@conn = Mongo::Connection.new
		@db = @conn.db(database_name)		
	end

	before :each do
		clean_mongo
		@persistance = DataPersistance.new(database_name)
	end

	def clean_mongo 
		@db.collection_names.each do |collection_name|
			@db[collection_name].remove
		end		
	end	

	context 'expired data checking' do
		@week = 604800
		let(:mdata){ {'metadata' => {'updated_at' => Time.now.to_i - 604800}} }
		let(:jdata){ {'metadata' => {'updated_at' => Time.now.to_i}} }

		it "expired if data is nil" do
			@persistance.expired?(nil, 1).should be true
		end

		it "expired if metadata.updated_at data is nil" do
			@persistance.expired?({metadata: {}}, 1).should be true
		end		

		{'zero' => 0, 
		 'less than week' => (@week - 1), 
		 'exactly a week' => @week }.each do |k,v|
				it "expired if data was updated a week ago and ttl is #{k} (#{v.inspect})" do
					@persistance.expired?(mdata, v).should be true
				end
		end

		{'nil' => nil, 
		 'more than week' => @week+1}.each do |k,v|
				it "NOT expired if data was updated a week ago and ttl is #{k} (#{v.inspect})" do
					@persistance.expired?(mdata, v).should be false
				end
		end
		
		{'nil' => nil, 
		 'more than week' => @week+1}.each do |k,v|
				it "NOT expired if data was updated just now and ttl is #{k} (#{v.inspect})" do
					@persistance.expired?(jdata, v).should be false
				end
		end		
	end

	context 'data caching when necesary based on ttl' do
		before :each do
			@week = 604800
			@data = {a: 1, b:2, c:3}
			@is_cached, @mongo_data = @persistance.cached('test',123456, true) do
				@data
			end
			@time = Time.now.to_i		
			@is_cached.should be false
		end

		it 'contains the update_at data' do
			@mongo_data['data'].should == @data
			@mongo_data['metadata']['updated_at'].should be_within(1.0).of(@time)
			@is_cached, @mongo_data = @persistance.cached('test',123456, true) do
				@data
			end
			@is_cached.should be true
		end

		{'nil' => nil, 'a week' => 604800 }.each do |k,v|
			it "should not renew cached if ttl is #{k} (#{v})" do
				new_data = @data.merge({d: 4})
				is_cached, mongo_data = @persistance.cached('test',123456, true, v) do
					new_data
				end
				is_cached.should be true
				@mongo_data['data'].should == @data
				@mongo_data['metadata']['updated_at'].should be_within(1.0).of(@time)			
			end
		end

		{'in the past' => -1, 'zero' => 0 }.each do |k,v|
			it "should renew cached if ttl is #{k} (#{v})" do
				new_data = @data.merge({d: 4})
				is_cached, mongo_data = @persistance.cached('test',123456, true, v) do
					new_data
				end
				is_cached.should be true
				@mongo_data['data'].should == new_data
				@mongo_data['metadata']['updated_at'].should be_within(1.0).of(@time)
			end
		end
	end

	context 'versioned data'
	context 'feeds data (posts, tweets)'
	context 'historical data (friends list)'  
	context 'diff data (friends list diff over time)'
end