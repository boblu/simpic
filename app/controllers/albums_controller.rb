class AlbumsController < ApplicationController
  layout 'simpic', :except => [:top]

	def top
		session[:user_read_level] = authority_name['guest'] if session[:user_read_level].blank?
		unless User.first
			redirect_to init_admin_users_url
			return
		end
		@app_name = APP_NAME
		authority_published = Album.authority(session[:user_read_level]).published
		@latest = authority_published.find(:all, :limit => 5)
		@top_rated = authority_published.find(:all, :limit => 5, :order => 'rating_average desc')
		@updated = authority_published.find(:all, :limit => 5, :order => 'updated_at desc')
		@copy_year_string = copyright_year_range
		@year_range = authority_published.year_range
	end
	
	def top_shown_new
		@pictures = Album.authority(session[:user_read_level]).published.first.pictures.authority(session[:user_read_level]).covered
 		render :action => "top_shown_new.xml.builder", :layout => false
	end
	
	def top_shown_all
		@pictures = Album.authority(session[:user_read_level]).published.inject([]){|pictures, album|
			pictures.concat(album.pictures.authority(session[:user_read_level]).covered)
		}
 		render :action => "top_shown_all.xml.builder", :layout => false
	end
	
	def show
		authority_published = Album.authority(session[:user_read_level]).published
		@app_name = APP_NAME
		@copy_year_string = copyright_year_range
		@year_range = authority_published.year_range
		if params[:dirname].blank?
			@album_list = authority_published.year(params[:year])
			@album = @album_list.first
			@active_year = params[:year]
		else
			@album_list = authority_published.year(params[:dirname][0..3])
			@album = Album.find_by_dirname(params[:dirname])
			@active_year = params[:dirname][0..3]
		end
		case @album.appearance
		when 0
      params[:page] = 1 if params[:page].blank?
      params[:per_page] = 30 if params[:per_page].blank?
			@pictures = @album.pictures.paginate(:page => params[:page], :per_page => params[:per_page])
		when 1
		when 2
		end
	end
	
	private
	
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
end
