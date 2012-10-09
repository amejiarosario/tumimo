class MongoTwitter
  attr_reader :mongodb
  attr_reader :twitter
  attr_reader :subject
  attr_accessor :ttl

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

    @ttl=nil
  end

  def friend_ids(ttl=@ttl)
    get_or_fetch(:friend_ids,ttl)
  end

  def follower_ids(ttl=@ttl)
    get_or_fetch(:follower_ids,ttl)
  end

  private
    def get_or_fetch(method, ttl=@ttl)
      method = method.to_sym
      data = @mongodb[method].find_one(_id: @subject[:id])
      
      if data.nil? || expired?(data,ttl)
        puts "CALLED: @twitter.#{method.to_s} for _id: #{@subject[:id]}"
        new_data = @twitter.send(method).to_a
        
        if data.nil?
          @mongodb[method].insert(prepare_insert(new_data))
        else # data expired
          @mongodb[method].update({_id: @subject[:id]}, prepare_update(new_data))
          @mongodb[method].update({_id: @subject[:id]}, {'$set' => { 'metadata.updated_at' => Time.now.to_i }})
        end

        new_data
      else
        (data['data_history'].last)['data']
      end      
    end

    def expired?(data, ttl)
      ttl.nil? ? false : (data['metadata']['updated_at'] < (Time.now.to_i - ttl))
    end

    def save_user_info(user)
      if @mongodb['user_info'].find_one(_id: user[:id].to_s).nil?
        id = @mongodb['user_info'].insert(prepare_insert(user))
      end
    end

    def prepare_data_element(data_hash)
      { 
        created_at: Time.now.to_i, 
        type: 'raw', # raw | diff
        data: data_hash
      }
    end

    def prepare_insert(data_hash, id=nil)
      {
        _id: id ? id : @subject[:id],
        metadata: {
          created_at: Time.now.to_i,
          updated_at: Time.now.to_i,
          version: '0.2',
          source: 'rails'
        },
        data_history: [prepare_data_element(data_hash)]
      }
    end

    def prepare_update(data_hash, id=nil)
      {
        '$push' => { 'data_history' => prepare_data_element(data_hash) }
      }
    end
end
