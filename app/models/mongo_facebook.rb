class MongoFacebook
  def initialize(access_token)
    @facebook = Koala::Facebook::API.new(access_token)
  end
  def me
    @facebook.get_object 'me'
  end
end
