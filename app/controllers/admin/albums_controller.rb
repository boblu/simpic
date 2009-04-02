class Admin::AlbumsController < ApplicationController
	layout 'admin'

	# before_filter :login_required

	def index
    @albums = Album.find_by_year_and_order(params[:year], params[:order]) 
    if @albums.blank?
      redirect_to new_admin_album_url(:blank=>true)
    else
			params[:page] = nil if params[:page].blank?
			params[:per_page] = 30 if params[:per_page].blank?
      @albums = @albums.paginate(params)
      @title = 'Album list'
      @sub_title = params[:year]
    end
	end

	def new
		@album = Album.new
		params[:from] = 'new'
		render :action => "modification"
	end
	
	def create
		@album = Album.new(params[:album])
		begin
			@album.save!
		rescue
			params[:from] = 'new'
			render :action => "modification"
		else
			redirect_to admin_albums_url
		end
	end
	
	def edit
		@album = Album.find(params[:id])
		params[:from] = 'edit'
		render :action => "modification"
	end
	
	def update
		@album = Album.find(params[:id])
		begin
			@album.update_attributes!(params[:album])
		rescue
			params[:from] = 'edit'
			render :action => "modification"
		else
			redirect_to admin_albums_url
		end
	end
	
	def destroy
		begin
			Album.transaction do
				params[:selected_id].each{|id| Album.find(id).destroy}
			end
		rescue
			flash[:error] = "Something wrong happened, can not delete albums."
		else
			flash[:notice] = "Albums deleted."
		end
		redirect_to admin_albums_url 
	end
end
