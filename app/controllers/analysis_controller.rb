class AnalysisController < ApplicationController
  before_filter :require_signed_in

  def index
  end

  def facebook
  	@user = current_user.facebook
  end
end
