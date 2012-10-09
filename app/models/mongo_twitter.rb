class MongoTwitter
  attr_reader :mongodb
  attr_reader :twitter
  attr_reader :subject

  def initialize(oauth_token, oauth_token_secret,
                 consumer_key = ENV['TUMIMO_TWITTER_KEY'], 
                 consumer_secret = ENV['TUMIMO_TWITTER_SECRET'],
                 mongo_server='localhost', mongo_port=27017)

    mongo_connection = Mongo::Connection.new(mongo_server,mongo_port)
    @mongodb = mongo_connection.db 'twitter'

    @twitter =  Twitter::Client.new(
      :consumer_key => consumer_key,
      :consumer_secret => consumer_secret,
      :oauth_token => oauth_token,
      :oauth_token_secret => oauth_token_secret
    )
    
    puts 'CALLED: @twitter.current_user'
    @subject = @twitter.current_user.to_hash
    save_user_info(@subject)
  end

  def friend_ids
    data = @mongodb['friend_ids'].find_one(_id: @subject[:id])
    if data.nil?
      puts 'CALLED: @twitter.friend_ids'
      data = @twitter.friend_ids.to_a
      @mongodb['friend_ids'].insert(prepare_data(data))
    end
    data['data']
  end

  def follower_ids
    data = @mongodb['follower_ids'].find_one(_id: @subject[:id])
    if data.nil?
      puts 'CALLED: @twitter.follower_ids'
      data = @twitter.follower_ids.to_a
      @mongodb['follower_ids'].insert(prepare_data(data))
    end
    data['data']
  end

  private
    def save_user_info(user)
      if @mongodb['user_info'].find_one(_id: user[:id].to_s).nil?
        id = @mongodb['user_info'].insert(prepare_data(user))
      end
    end

    def prepare_data(data_hash, id=nil)
      {
        _id: id ? id : @subject[:id],
        metadata: {
          created_at: Time.now,
          updated_at: Time.now,
          source: 'mongo_twitter.rb'
        },
        data: data_hash
      }
    end
end
