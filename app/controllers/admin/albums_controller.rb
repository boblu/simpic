class Admin::AlbumsController < ApplicationController
	layout 'admin'

	# before_filter :login_required

	def index
		@albums = Album.find(:all)
	end

	def new
		@album = Album.new
	end
	
	def create
		@album = Album.new(params[:album])
		begin
			@album.save!
		rescue
			render :action => :new
		else
			flash[:notice] = 'Album was successfully created.'
			redirect_to admin_albums_url
		end
	end
	
	def edit
		@album = Album.find(params[:id])
	end
	
	def update
		@album = Album.find(params[:id])
		begin
			@album.update_attributes!(params[:album])
		rescue
			render :action => :edit
		else
			flash[:notice] = 'Album was successfully updated.'
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
