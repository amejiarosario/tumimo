OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  
  provider :twitter, ENV['TUMIMO_TWITTER_KEY'], ENV['TUMIMO_TWITTER_SECRET']
  
  provider :facebook, ENV['TUMIMO_FACEBOOK_KEY'], ENV['TUMIMO_FACEBOOK_SECRET'], 
  	scope: "read_stream,user_birthday,user_religion_politics,user_relationships,user_relationship_details,user_hometown,user_location,user_likes,user_activities,user_interests,user_education_history,user_work_history,user_online_presence,user_website,user_groups,user_events,user_photos,user_videos,user_photo_video_tags,user_notes,user_about_me,user_status,friends_birthday,friends_religion_politics,friends_relationships,friends_relationship_details,friends_hometown,friends_location,friends_likes,friends_activities,friends_interests,friends_education_history,friends_work_history,friends_online_presence,friends_website,friends_groups,friends_events,friends_photos,friends_videos,friends_photo_video_tags,friends_notes,friends_about_me,friends_status"
end