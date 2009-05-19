class AlbumsController < ApplicationController
  layout 'simpic', :except => [:top]

  before_filter :setup_negative_captcha, :only => [:show, :comment]
  before_filter :update_span_when_navi, :only => [:show, :comment, :top]

	def top
		unless User.first
			redirect_to init_admin_users_url
			return
		end
		@app_name = APP_NAME
		authority_published = Album.authority(current_read_level).published
		@latest = authority_published.find(:all, :limit => 5)
		@top_rated = authority_published.find(:all, :limit => 5, :order => 'rating_average desc')
		@updated = authority_published.find(:all, :limit => 5, :order => 'updated_at desc')
		@latest_comments = Comment.authority_latest(current_read_level)
		@copy_year_string = copyright_year_range
		@year_range = authority_published.year_range
	end
	
	def top_shown_new
		@pictures = Album.authority(current_read_level).published.first.pictures.authority(current_read_level).covered
 		render :action => "xml_feeds.xml.builder", :layout => false
	end
	
	def top_shown_all
		@pictures = Album.authority(current_read_level).published.inject([]){|pictures, album|
			pictures.concat(album.pictures.authority(current_read_level).covered)
		}
    @http_header = request.protocol + request.host_with_port
 		render :action => "cooliris_album.xml.builder", :layout => false
	end
	
	def cooliris
		@contents = Album.find(params[:album_id]).pictures.authority(current_read_level)
		@pictures = @contents.paginate(:page => params[:id], :per_page => PER_PAGE)
    @http_header = request.protocol + request.host_with_port
		@previous = params[:id].to_i==1 ? false : true
		@next = PER_PAGE*params[:id].to_i>=@contents.size ? false : true
    @for_album = true
		render :action => "cooliris_album.xml.builder", :layout => false
	end
	
	def show
		authority_published = Album.authority(current_read_level).published
		@app_name = APP_NAME
		@copy_year_string = copyright_year_range
		@year_range = authority_published.year_range
		if params[:dirname].blank?
			@album_list = authority_published.year(params[:year])
			@album = @album_list.first
			@active_year = params[:year]
		else
			@album_list = authority_published.year(params[:dirname][0..3])
			@album = @album_list.find_by_dirname(params[:dirname])
			@active_year = params[:dirname][0..3]
		end
		case @album.appearance
		when 0
      params[:page] = 1 if params[:page].blank?
      params[:per_page] = PER_PAGE if params[:per_page].blank?
			@pictures = @album.pictures.authority(current_read_level).paginate(:page => params[:page], :per_page => params[:per_page])
	  when 1, 3
      @pictures = @album.pictures.authority(current_read_level)
      if not params[:xml].blank? and params[:xml] == 'true'
        render :action => "xml_feeds.xml.builder", :layout => false
        return
      end
		end
	end

	def comment
		@album = Album.find(params[:id])
		if @captcha.valid?
			begin
				@album.comments.create!(@captcha.values)
		  rescue
        redirect_to :back
      else
        redirect_to url_for(:controller => :albums, :action => :show, :dirname => @album.dirname, :anchor => "comment_#{@album.comments.first.id}")
      end
		end
  end
end
