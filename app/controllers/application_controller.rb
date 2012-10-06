class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  	def current_user
  		@current_user ||= User.find(session[:user_id]) if session[:user_id]
		rescue ActiveRecord::RecordNotFound
		  session[:user_id] = nil
  	end

  	def user_signed_in?
  		!current_user.nil?
  	end

  	helper_method :current_user, :user_signed_in?
end
