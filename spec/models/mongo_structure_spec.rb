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
		let(:mdata){ {metadata: {updated_at: Time.now.to_i - 604800}} }

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
	end

	context 'data and expirations' do
		before :each do
			@data = {a: 1, b:2, c:3}
			@is_cached, @mongo_data = @persistance.cached('test',123456, true) do
				@data
			end
			@time = Time.now.to_i		
		end

		it 'contains the update_at data' do
			@is_cached.should be false
			@mongo_data[:data].should == @data
			@mongo_data[:metadata][:updated_at].should be_within(1.0).of(@time)
		end

		{'nil' => nil, 'in the future' => Time.now.to_i+1 }.each do |k,v|
			it "should not renew cached if ttl is #{k} (#{v})" do
				new_data = @data.merge({d: 4})
				is_cached, mongo_data = @persistance.cached('test',123456, true, v) do
					new_data
				end
				is_cached.should be true
				@mongo_data[:data].should == @data
				@mongo_data[:metadata][:updated_at].should be_within(1.0).of(@time)			
			end
		end

		{'now' => Time.now.to_i, 'in the past' => Time.now.to_i-1, 'zero' => 0 }.each do |k,v|
			it "should renew cached if ttl is #{k} (#{v})" do
				new_data = @data.merge({d: 4})
				is_cached, mongo_data = @persistance.cached('test',123456, true, v) do
					new_data
				end
				is_cached.should be true
				@mongo_data[:data].should == new_data
				@mongo_data[:metadata][:updated_at].should be_within(1.0).of(@time)
			end
		end
	end

	context 'versioned data'
	context 'feeds data (posts, tweets)'
	context 'historical data (friends list)'  
	context 'diff data (friends list diff over time)'
end