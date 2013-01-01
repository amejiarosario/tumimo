class AnalysisController < ApplicationController
  before_filter :require_signed_in

  def index
  end

  def facebook
  	@me = current_user.send_job('me').try(:[],'data').try(:[],'raw')
  	@friend_ids = current_user.send_job('friend_ids').try(:[],'data').try(:[],'raw')
  	@feed = current_user.send_job('feed').try(:[],'data').try(:[],'raw')
  	#@me = current_user.mfb.me['data']['raw']
  	# @friend_ids = current_user.mfb.friend_ids['data']['raw']
  end
end
