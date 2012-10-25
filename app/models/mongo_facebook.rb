
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
    data.cached 'get_object__me', uid, cache_indicator do
      facebook.get_object 'me'
    end
  end

  def friend_ids(cache_indicator=false, ttl=nil)
    data.cached 'get_connections__me_friends', uid, cache_indicator do
      facebook.get_connections 'me', 'friends'
    end
  end
end
