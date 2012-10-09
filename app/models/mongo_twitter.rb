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

    @subject = @twitter.current_user.to_hash
    save_user_info(@subject)
  end

  def friend_ids
    get_or_fetch(:friend_ids)
  end

  def follower_ids
    get_or_fetch(:follower_ids)
  end

  private
    def get_or_fetch(method, predata=nil)
      method = method.to_sym
      data = @mongodb[method].find_one(_id: @subject[:id])
      if data.nil?
        puts "CALLED: @twitter.#{method.to_s} for _id: #{@subject[:id]}"
        data = predata ? predata : @twitter.send(method).to_a
        @mongodb[method].insert(prepare_data(data))
        data
      else
        data['data']
      end      
    end

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
