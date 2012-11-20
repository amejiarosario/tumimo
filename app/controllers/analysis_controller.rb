class AnalysisController < ApplicationController
  before_filter :require_signed_in

  def index
  end

  def facebook
  	@me = current_user.mfb.me['data']['raw']
  	@friend_ids = current_user.mfb.friend_ids['data']['raw']
  end
end
