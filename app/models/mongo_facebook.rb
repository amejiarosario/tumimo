class MongoFacebook
  attr_accessor :facebook
  attr_accessor :data
  attr_reader :uid

  def initialize(uid,access_token)
    @facebook = Koala::Facebook::API.new(access_token)
    @data = DataPersistance.new 'facebook'
    @uid = uid
  end
  
  def me(cache_indicator=false, ttl=nil)
    data.fetch 'get_object__me', uid, cache_indicator: cache_indicator, ttl: ttl do
      facebook.get_object 'me'
    end
  end

  def friend_ids(cache_indicator=false, ttl=nil)
    # FIXME data_type: 'diff' and add test cases
    data.fetch 'get_connections__me_friends', uid, data_type: 'raw', cache_indicator: cache_indicator, ttl: ttl do
      facebook.get_connections 'me', 'friends'
    end
  end

  def feed(limit=nil, cache_indicator=false)
    data.fetch 'get_connections__me_feed', uid, data_type: 'feed', limit: limit, cache_indicator: cache_indicator do
      facebook.get_connections 'me', 'feed'
    end
  end
end
