class Admin::AlbumsController < ApplicationController
  layout 'admin'

  before_filter :authorize_admin

  def index
    @title = 'Album list'
    if params[:search_condition].blank?
      @albums = Album.find_by_year_or_condition_with_order(nil, params[:year], params[:order])
	    if params[:year].blank? and @albums.blank?
	      redirect_to new_admin_album_url(:blank=>true)
	      return
	    end
	    @sub_title = params[:year]
    else
      @albums = Album.find_by_year_or_condition_with_order(params[:search_condition], nil, params[:order])
      @sub_title = 'Condition: ' + params[:search_condition]
    end
		if @albums.blank?
			flash[:notice] = "Cannot find albums with '#{params[:search_condition]}'."
			redirect_to :back
		else
      params[:page] = 1 if params[:page].blank?
      params[:per_page] = 30 if params[:per_page].blank?
      @albums = @albums.paginate(:page => params[:page], :per_page => params[:per_page])
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
      redirect_to admin_albums_url(:year => params[:year], :order => params[:order], :page => params[:page], :per_page => params[:per_page])
    end
  end
  
  def batch_action
    if params[:commit] == 'Search'
      redirect_to admin_albums_url(:search_condition => params[:search_condition])
    elsif params[:selected_id].blank?
			redirect_to :back
    else
      begin
        Album.transaction do
          if params[:commit] == 'Delete'
            params[:selected_id].each{|id| Album.find(id).destroy}
          else
            params[:commit] == 'Publish' ? publish_value = true : publish_value = false
            params[:selected_id].each{|id| Album.find(id).update_attributes!(:publish => publish_value)}
          end
        end
      end
      redirect_to admin_albums_url(:year => params[:year])
    end
  end
  
  def rate
 		@album = Album.find(params[:id])
 		@album.rate(params[:stars], current_user, params[:dimension])
 		id = "ajaxful-rating-" + (!params[:dimension].blank? ? "#{params[:dimension]}-" : "album-#{@album.id}")
 		render :update do |page|
	 		page.replace_html id, ratings_for(@album, :wrap => false, :dimension => params[:dimension], :remote_options => {:url => rate_admin_album_path(@album)})
 			page.visual_effect :highlight, id
 		end
  end
end
