# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	helper_method :current_user
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
	include Settings
  
	private

  def current_user
		User.find(session[:user_id])
	end
  
  def authorize_admin
  	if session[:user_id].blank?
      flash[:notice] = "<ul><li>You are not administrator!</li></ul>"
      redirect_to root_url
      return
    else
      temp = User.find_by_id(session[:user_id])
  		if temp.blank? or temp.read_level != 0
	      flash[:notice] = "<ul><li>You are not administrator!</li></ul>"
	      redirect_to root_url
  		end
    end
  end
end
