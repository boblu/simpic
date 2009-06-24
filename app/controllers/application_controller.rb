# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	helper_method :logged_in?, :current_user, :current_read_level, :authority_name_list
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

	protected

#	Use this when testing production environment	
#	 def local_request?
#		 false
#	 end

	private

  def logged_in?
    session[:user_id].blank? ? false : true
  end

  def current_user
		User.find(session[:user_id])
	end
	
	def current_read_level
		logged_in? ? current_user.read_level : 50
  end

  def authorize_admin
  	unless current_read_level == 0
      flash[:notice] = "<ul><li>You are not administrator!</li></ul>"
      redirect_to root_url
      return
		end
  end
	
  def app_settings(property="")
  	App.first.settings[property]
  end

  def authority_name_list
  	app_settings("authority_name")
  end

	def get_authorized_published_albums
		@authorized_published_albums = Album.authority(current_read_level).published
	end

  def get_parameters_for_layout
		@layout_app_name = app_settings("app_name")
		@layout_latest = @authorized_published_albums.find(:all, :limit => 5)
		@layout_rated = @authorized_published_albums.find(:all, :limit => 5, :order => 'rating_average desc').select{|album| album.rating_average != 0}
		@layout_updated =  @authorized_published_albums.find(:all, :limit => 5, :order => 'inserted_at desc')
		@layout_comments = Comment.authority_latest(current_read_level)
		@layout_year_range = @authorized_published_albums.year_range
		year_range = Album.year_range
		@layout_copyright = case year_range.size
    when 0 then nil
    when 1 then year_range[0]
    else year_range.last.to_s + ' ~ ' + year_range.first.to_s
    end
	end
	
	def get_parameters_for_left_column
		if params[:dirname].blank?
			@album_list = @authorized_published_albums.year(params[:year])
			@album = @album_list.first
			@active_year = params[:year]
		else
			@album_list = @authorized_published_albums.year(params[:dirname][0..3])
			@album = @album_list.find_by_dirname(params[:dirname])
			@active_year = params[:dirname][0..3]
		end
	end

	def redirect_to_root_url_if_not_authenticaed
		if @album.blank?
			flash[:error] = "Need password to see contents!"
			redirect_to root_url
		end
	end

  def setup_negative_captcha
    @captcha = NegativeCaptcha.new(
      :secret => NEGATIVE_CAPTCHA_SECRET, #A secret key entered in environment.rb.  'rake secret' will give you a good one.
      :spinner => request.remote_ip, 
      :fields => [:name, :email, :content], #Whatever fields are in your form 
      :params => params)
  end

  def update_span_when_navi
  	current_user.update_attributes!(:span => ((current_user.end_time - Time.now)/60).round) unless [0, 50].include?(current_read_level)
  end
end
