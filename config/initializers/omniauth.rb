Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  provider :twitter, ENV['TUMIMO_TWITTER_KEY'], ENV['TUMIMO_TWITTER_SECRET']
  provider :facebook, ENV['TUMIMO_FACEBOOK_KEY'], ENV['TUMIMO_FACEBOOK_SECRET']
end