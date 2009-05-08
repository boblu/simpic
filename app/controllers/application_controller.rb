# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	helper_method :current_user
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
	include Settings

  def update_timer
  	new_span = current_user.span - 1 if current_user.begin_time < Time.now
  	current_user.update_attributes!(:span => new_span)
  	if current_user.span < 0
  		render :update do |page|
  			page.redirect_to logout_admin_users_url(:id => session[:user_id])
			end
  	else
  		render :update do |page|
  			page.replace 'timer',  :inline => "<span id='timer'><%= h(current_user.span) %></span>"
			end
  	end
  end

	private

  def current_user
  	unless session[:user_id].blank?
			User.find(session[:user_id])
		end
	end
  
  def authorize_admin
  	unless (not current_user.blank? and current_user.read_level == 0)
      flash[:notice] = "<ul><li>You are not administrator!</li></ul>"
      redirect_to root_url
      return
		end
  end

  def copyright_year_range
    year_range = Album.year_range
    copy_year_string = nil
    case year_range.size
    when 0 then copy_year_string = nil
    when 1 then copy_year_string = year_range[0]
    else copy_year_string = year_range.last.to_s + ' ~ ' + year_range.first.to_s
    end
    return copy_year_string
  end

  def setup_guest_read_level
    session[:user_read_level] = authority_name['guest'] if session[:user_read_level].blank?
  end
end
