class MongoFacebook
  attr_accessor :facebook
  attr_accessor :data
  attr_reader :uid

  def initialize(uid,access_token)
    raise "MongoFacebook constructor requires `uid' (#{uid}) and `access_token' (#{access_token})" if uid.nil? && access_token.nil?
    @facebook = Koala::Facebook::API.new(access_token)
    @data = DataPersistance.new 'facebook'
    @uid = uid
  end
  
  def me(options = {})
    data.fetch 'get_object__me', uid, options do
      facebook.get_object uid
    end
  end

  def friend_ids(options = {})
    # FIXME data_type: 'diff' and add test cases
    data.fetch 'get_connections__me_friends', uid, options do
      facebook.get_connections uid, 'friends'
    end
  end

  def feed(options = {})
    # TODO get metadata while fetching like last data post
    # FIXME detect if the feed fetching was interrrupted or imcomplete
    data.fetch 'get_connections__me_feed', uid, options.merge(data_type: 'feed') do
      facebook.get_connections uid, 'feed'
    end
  end

  # def process_feed(options = {})
  #   col = data.db.collection("get_connections__me_feed")
  #   if col.count > 0
  #     feeds = col.find(uid: uid).to_a.first
  #     joined_facebook = feeds["data"]["raw"].last["created_time"]
  #   end
  # end
end
