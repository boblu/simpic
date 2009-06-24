class AlbumsController < ApplicationController
  layout 'simpic'
	
  before_filter :setup_negative_captcha, :only => [:show, :comment]
  before_filter :update_span_when_navi, :only => [:show, :top]
	before_filter :get_authorized_published_albums, :only => [:top_shown_new, :cooliris, :show, :top]
  before_filter :get_parameters_for_layout, :only => [:show, :top]
  before_filter :get_parameters_for_left_column, :only => [:show]
  before_filter :redirect_to_root_url_if_not_authenticaed, :only => [:show]

	###########################
	## XML Feeds
	###########################
	def top_shown_new
		@pictures = @authorized_published_albums.first.pictures.authority(current_read_level).covered
		@xml_type = "top_shown_new"
 		render :action => "xml_feeds.xml.builder", :layout => false
	end

	def albums
		@app_name = app_settings("app_name")
		@latest = Album.authority(authority_name_list["guest"]).published.find(:all, :limit => 5)
		@http_header = http_header
		@xml_type = "site_rss_feed"
		render :action => "xml_feeds.xml.builder", :layout => false
	end
	
	def cooliris
		if params[:album_id].blank?
			@pictures = @authorized_published_albums.inject([]){|pictures, album| pictures.concat(album.pictures.authority(current_read_level).covered)}
	    @http_header = http_header
	  else
			@contents = Album.find(params[:album_id]).pictures.authority(current_read_level)
			@pictures = @contents.paginate(:page => params[:id], :per_page => app_settings("per_page"))
	    @http_header = http_header
			@previous = params[:id].to_i==1 ? false : true
			@next = app_settings("per_page")*params[:id].to_i>=@contents.size ? false : true
	    @for_album = true
		end
		render :action => "cooliris_album.xml.builder", :layout => false
	end

  def render_xml
  	@album = Album.find(params[:id])
  	@pictures = @album.pictures.authority(current_read_level)
  	case @album.appearance
		when 1
			@xml_type = "album_jw_image_rotator"
		when 3
			@xml_type = "album_simple_viewer"
    	@imagePath = http_header + File.dirname(@pictures[0].normal_url) + '/'
    	@thumbPath = http_header + File.dirname(@pictures[0].thumb_url) + '/'
    end
    render :action => "xml_feeds.xml.builder", :layout => false
  end

	###########################
	## Ordinary methods
	###########################
	def top
		redirect_to(init_admin_users_url) unless User.first
	end

	def show
		case @album.appearance
		when 0
      params[:page] = 1 if params[:page].blank?
      params[:per_page] = app_settings("per_page") if params[:per_page].blank?
			@pictures = @album.pictures.authority(current_read_level).paginate(:page => params[:page], :per_page => params[:per_page])
	  when 1, 3
      @pictures = @album.pictures.authority(current_read_level)
		end
	end

	def comment
		@album = Album.find(params[:id])
		if @captcha.valid?
			begin
				new_comment = @album.comments.create!(@captcha.values)
			end
			respond_to do |format|
				format.html {redirect_to url_for(:controller => :albums, :action => :show, :dirname => @album.dirname, :anchor => "comment_#{@album.comments.first.id}")}
				format.js {
					render :update do |page|
						page.insert_html :bottom, :comment_container, :partial => 'each_comment', :object => new_comment, :locals=>{:each_comment_counter => (@album.comments.size==1 ? 0 : nil)}
						page["old_comments"].show if @album.comments.size==1
						page["new_comment_form"].reset
					end
				}
			end
		end
  end
  
  private
  	def http_header
  		request.protocol + request.host_with_port
  	end
end
