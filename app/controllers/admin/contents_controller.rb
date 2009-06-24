class Admin::ContentsController < ApplicationController
  layout 'admin'

  before_filter :authorize_admin, :except => [:rate]

  def index
    @album = Album.find(params[:album_id])
    @title = @album.title
    @subtitle = @album.begin_on.to_s(:number) + '~' + @album.end_on.to_s(:number) + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tags:' + @album.tag_list.join(', ')
    params[:page] = 1 if params[:page].blank?
    params[:per_page] = 30 if params[:per_page].blank?
    temp_collection = params[:filter].blank? ? @album.pictures : @album.pictures.authority_filter(params[:filter])
    case params[:order]
    when "read_level asc" then collection = temp_collection.sort_by{|item| item.read_level}
    when "read_level desc" then collection = temp_collection.sort_by{|item| item.read_level}.reverse
    when "comments,asc" then collection = temp_collection.sort_by{|item| item.comments.size}
    when "comments,desc" then collection = temp_collection.sort_by{|item| item.comments.size}.reverse
    when "rating_average asc" then collection = temp_collection.sort_by{|item| item.rating_average}
    when "rating_average desc" then collection = temp_collection.sort_by{|item| item.rating_average}.reverse
    when "display_order asc" then collection = temp_collection
    when "display_order desc" then collection = temp_collection.reverse
    when "top_shown asc" then collection = temp_collection.sort_by{|item| item.top_shown.to_s}
    when "top_shown desc" then collection = temp_collection.sort_by{|item| item.top_shown.to_s}.reverse
    else collection = temp_collection
    end
    @picture_size = collection.size
    @pictures = collection.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def new
  	@album = Album.find(params[:album_id])
  	@sub_title = @album.begin_on.year.to_s + '      ' + @album.title
  	@filenames = get_all_pictures_in_upload_dir
  end
  
  def create
		@album = Album.find(params[:album_id])
		begin
			if params[:type] == 'picture'
				if params[:pattern] == 'local'
					params[:filenames].each{|file| @album.contents.create!(:content_type => 'picture', :temp_filename => file)}
					redirect_to admin_album_contents_url
				elsif params[:pattern] == 'remote'
					@album.contents.create!(:album_id => @album.id, :swf_uploaded_picture => params[:Filedata])
					render :nothing => true
				end
			elsif params[:type] == 'video'
			end
		end
  end

  def edit
    @album = Album.find(params[:album_id])
    @content = Content.find(params[:id])
  end

  def update
    @content = Content.find(params[:id])
    begin
      @content.update_attributes!(params[:content])
    rescue
      @album = @content.album
      render :action => :edit
    else
      redirect_to admin_album_contents_url
    end
  end

  def batch_action
  	if params[:commit] == "Filter"
  		redirect_to admin_album_contents_url(:filter => params[:filter])
  	else
	    if params[:selected_id].blank?
	      redirect_to :back
	    else
	      begin
	        Content.transaction do
	          if params[:commit] == 'Delete'
	            params[:selected_id].each{|id| Content.find(id).destroy}
	          elsif params[:commit] == 'Set'
	            params[:selected_id].each{|id| Content.find(id).update_attributes!(:read_level => params[:read_level].to_i)}
	          else
	            params[:commit] == 'Cover' ? top_shown = true : top_shown = false
	            params[:selected_id].each{|id| Content.find(id).update_attributes!(:top_shown => top_shown)}
	          end
	        end
	      end
	      redirect_to Album.find(params[:album_id]).contents.blank? ? admin_albums_url : request.referer
	    end
	  end
  end

  def rate
    @content = Content.find(params[:id])
    @content.rate(params[:stars], current_user, params[:dimension])
    id = "simpic-rating-" + (!params[:dimension].blank? ? "#{params[:dimension]}-" : "content-#{@content.id}")
    if params[:small_stars].blank?
      small_stars = false
      url = rate_admin_album_content_path(@content.album, @content)
    else
      small_stars = true
      url = rate_admin_album_content_path(@content.album, @content, :small_stars => true)
    end
    render :update do |page|
      page.replace_html id, ratings_for(@content, :wrap => false,
                                                  :dimension => params[:dimension],
                                                  :small_stars => small_stars,
                                                  :remote_options => {:url => url})
      page.visual_effect :highlight, id
    end
  end

	def sort
		@album = Album.find(params[:album_id])
		@pictures = @album.pictures
		@title = 'Sorting pictures'
	end
	
	def save_sort
		params[:sort_results].scan(/\d+/).each_with_index{|id, index| Content.find(id).update_attributes!(:display_order => index+1)}
		redirect_to admin_album_contents_url
	end

	def oncover
    @content = Content.find(params[:id])
    begin
      @content.update_attributes!(:top_shown => params[:top_shown])
    end
    img_link = @content.top_shown==true ? "image_tag('admin/publish_y.png')" : "image_tag('admin/publish_x.png')"
    url_link = oncover_admin_album_content_url(@content.album.id, @content.id, :top_shown => (@content.top_shown==true ? 'false' : 'true'))
    render :update do |page|
			page.replace_html 'oncover_'+params[:id], :inline => "<%= link_to_remote(#{img_link}, :url => '#{url_link}', :method => :get) %>"
		end
	end
	
  private
  
  def get_all_pictures_in_upload_dir(directory = eval(app_settings("tmp_pic_dir"))+'/')
  	filenames = Array.new
  	Dir.foreach(directory){|xyz|
  		next if ['.', '..'].include?(xyz)
			if File.directory?(directory + xyz)
				temp = get_all_pictures_in_upload_dir(directory + xyz + '/').map{|item| [xyz+'/'+item[0], xyz+'/'+item[1]]}
				temp.blank? ? FileUtils.rm_rf(directory + xyz) : filenames.concat(temp)
			else
				filenames << [xyz, xyz] if File.extname(xyz) =~ /(jpg|jpeg|gif|png|bmp)/i
			end
  	}
  	return filenames.sort
  end
end