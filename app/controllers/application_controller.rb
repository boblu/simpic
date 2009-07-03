# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  before_filter :get_app_setting
  before_filter :set_locale
  
	helper_method :logged_in?,
                :current_user,
                :current_read_level,
                :authority_name_list,
                :default_url_options,
                :get_named_locale_path_or_url


	protected

#	Use this when testing production environment	
#	 def local_request?
#		 false
#	 end

	private
  def get_app_setting
    @app_setting ||= App.first.settings
  end
  
  def set_locale
    if params[:locale].blank?
      I18n.locale = @app_setting["default_locale"].to_sym
    else
      I18n.locale = params[:locale].to_sym
    end
  end
  
  def logged_in?
    session[:user_id].blank? ? false : true
  end

  def current_user
    User.find(session[:user_id])
  end
  
  def current_read_level
    logged_in? ? current_user.read_level : 50
  end

  def authority_name_list
    @app_setting["authority_name"]
  end
  
  def default_url_options(options={})
    { :locale => I18n.locale } unless I18n.locale == @app_setting["default_locale"].to_sym
  end
  
  def get_named_locale_path_or_url(orig_path_or_url)
    I18n.locale == @app_setting["default_locale"].to_sym ? eval(orig_path_or_url) : eval('locale_' + orig_path_or_url)
  end

  def authorize_admin
    unless current_read_level == 0
      flash[:notice] = "<ul><li>You are not administrator!</li></ul>"
      redirect_to root_url
      return
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
    unless current_read_level == 50 or current_user.span == -100
      current_user.update_attributes!(:span => (current_user.end_time.to_i - Time.now.to_i))
    end
  end

  def get_authorized_published_albums
    @authorized_published_albums ||= Album.authority(current_read_level).published
  end

  def get_parameters_for_layout
    @layout_app_name ||= @app_setting["app_name"]
    @layout_latest ||= @authorized_published_albums.find(:all, :limit => 5)
    @layout_rated ||= @authorized_published_albums.find(:all, :limit => 5, :order => 'rating_average desc').select{|album| album.rating_average != 0}
    @layout_updated ||=  @authorized_published_albums.find(:all, :limit => 5, :order => 'inserted_at desc')
    @layout_comments ||= Comment.authority_latest(current_read_level)
    @layout_year_range ||= @authorized_published_albums.year_range
    year_range = Album.year_range
    @layout_copyright ||= case year_range.size
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
end
