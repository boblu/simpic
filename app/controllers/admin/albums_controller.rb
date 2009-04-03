class Admin::AlbumsController < ApplicationController
  layout 'admin'

  # before_filter :login_required

  def index
    @title = 'Album list'
    if params[:search_condition].blank?
      @albums = Album.find_by_year_or_condition_with_order(nil, params[:year], params[:order])
      @sub_title = params[:year]
    else
      @albums = Album.find_by_year_or_condition_with_order(params[:search_condition], nil, params[:order])
      @sub_title = 'Condition: ' + params[:search_condition]
    end
    if params[:year].blank? and @albums.blank?
      redirect_to new_admin_album_url(:blank=>true)
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
end
