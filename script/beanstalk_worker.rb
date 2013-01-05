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

# Stalker.enqueue('facebook.me', oauth1: '895685163', oauth2: 'AAAFNKZCBGXpABAHQoMDIdLOABlzr4f8KHzUNXDTga0m9MfXEsVnM1gATNNsbcQpX7iFzrSIVC64ChO9ZAMDheowcGxyzRAPHrRNtU65AZDZD')
job 'facebook.me' do |args|
	args = hashWithIndifferentAccess(args)
	mfb = MongoFacebook.new(args[:oauth1], args[:oauth2])
	data = mfb.me(args)
	log "mfb.me=#{data.inspect}"
end

job 'facebook.friend_ids' do |args|
	args = hashWithIndifferentAccess(args)
	puts "args=#{args.inspect}"
	mfb = MongoFacebook.new(args[:oauth1], args[:oauth2])
	data = mfb.friend_ids(args)
	log "mfb.friend_ids=#{data.inspect}"
end

job 'facebook.feed' do |args|
	args = hashWithIndifferentAccess(args)
	mfb = MongoFacebook.new(args[:oauth1], args[:oauth2])
	data = mfb.feed(args)	
	log "mfb.feed=#{data.inspect}"
end

job 'debug.raise.error' do |args|
	raise "This is an error!! (just testing)"
end

error do |e,job,args|
	log "ERROR e.inspect=<#{e.inspect}>, job.inspect=<#{job.inspect}>, args=<#{args.inspect}>"
end
