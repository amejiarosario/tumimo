class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_signed_in
    redirect_to sign_in_path, notice: 'You need to sign in first.' unless user_signed_in?
    return false
  end

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
