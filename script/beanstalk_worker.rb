require 'koala'
require 'mongo'
require_relative '../app/models/mongo_facebook'
require_relative '../app/models/data_persistance'

require 'stalker'
include Stalker

def hashWithIndifferentAccess(hash)
	new_hash = {}
	hash.each do |k,v|
		new_hash[k.to_sym] = v
	end
	new_hash.merge(hash)
end

#TODO avoid same tasks being requested more than once

job 'ping' do |args|
	File.open("tmp/pong.txt", "a") { |file| file.puts "ping: #{Time.now} - #{args.inspect}" }
end

job 'facebook.me' do |args|
	args = hashWithIndifferentAccess(args)
	mfb = MongoFacebook.new(args[:oauth1], args[:oauth2])
	data = mfb.me(args)
	puts "mfb.me=#{data.inspect}"

	error do |e,job,args|
		puts "ERROR #{e.inspect}, #{job.inspect}, #{args.inspect}"
	end
end

job 'facebook.friend_ids' do |args|
	args = hashWithIndifferentAccess(args)
	puts "args=#{args.inspect}"
	mfb = MongoFacebook.new(args[:oauth1], args[:oauth2])
	mfb.friend_ids(args)
end

job 'facebook.feed' do |args|
	args = hashWithIndifferentAccess(args)
	mfb = MongoFacebook.new(args[:oauth1], args[:oauth2])
	mfb.feed(args)	
end