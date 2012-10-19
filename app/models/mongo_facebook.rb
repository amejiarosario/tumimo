class MongoFacebook
  attr_reader :mongodb
  attr_reader :facebook
  attr_reader :subject
  attr_accessor :ttl

  # TODO: implemenet md5checksum for FQL 

  def initialize(oauth_token, oauth_token_secret=nil,
                 consumer_key = ENV['TUMIMO_FACEBOOK_KEY'], 
                 consumer_secret = ENV['TUMIMO_FACEBOOK_SECRET'],
                 mongo_server='localhost', mongo_port=27017)

    mongo_connection = Mongo::Connection.new(mongo_server,mongo_port)
    @mongodb = mongo_connection.db 'facebook'

    @facebook = Koala::Facebook::API.new(oauth_token)

    # FIXME: get it from oauth token instead.
    @subject = @facebook.get_object('me') 
    save_user_info(@subject)

    @ttl=nil
  end

  def uid
    @subject['id']
  end

  def friend_ids(ttl=@ttl)
    # ids = facebook_friends.map { |e| e['id'] }.join(', ')
    get_or_fetch(:get_connections,:me,:friends,ttl)
  end

  def user_data(ids, ttl=@ttl)
    query = "SELECT uid, name, pic_square FROM user WHERE uid = me() \
      OR uid IN (SELECT uid2 FROM friend WHERE uid1 = me())"
    get_or_fetch(:fql_query,query,ttl)
  end

  def user_feeds
    get_or_fetch(:get_connections,:me,:feed,ttl)
  end

  private
    def get_or_fetch(method, subject, action, ttl=@ttl, fetch_nexts=true)
      mongoname = "#{method}__#{subject}__#{action}"
      args = [method, subject, action].compact
      
      data = @mongodb[mongoname].find_one(_id: uid)
      
      if data.nil? || expired?(data,ttl)
        puts "***** CALLED: @facebook.#{method.to_s} for _id: #{uid} ****"
        new_data = @facebook.send(*args).to_a
        
        if data.nil? # new_date
          @mongodb[mongoname].insert(prepare_insert(new_data))
        else # data expired
          @mongodb[mongoname].update({_id: uid}, prepare_update(new_data))
          @mongodb[mongoname].update({_id: uid}, {'$set' => { 'metadata.updated_at' => Time.now.to_i }})
        end

        new_data
      else
        (data['data_history'].last)['data']
      end      
    end

    def insert_mongo_data(collection_name, data, update=false)
      
    end

    def expired?(data, ttl)
      ttl.nil? ? false : (data['metadata']['updated_at'].to_i < (Time.now.to_i - ttl))
    end

    def save_user_info(user)
      if @mongodb['user_info'].find_one(_id: user['id'].to_s).nil?
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
        _id: id ? id : uid,
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
