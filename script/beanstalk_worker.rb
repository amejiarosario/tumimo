require 'mongo'
require_relative '../app/models/data_persistance'
require 'koala'
require_relative '../app/models/mongo_facebook'

require 'stalker'
include Stalker

job 'ping' do |args|
	File.open("tmp/pong.txt", "a") { |file| file.puts "ping: #{Time.now} - #{args.inspect}" }
end

job 'facebook.me' do |args|
end

job 'facebook.friend_ids' do |args|
end

job 'facebook.feed' do |args|
end