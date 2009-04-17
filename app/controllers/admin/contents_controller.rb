class Admin::ContentsController < ApplicationController
  layout 'admin'
  
  def index
    @album = Album.find(params[:album_id])
    @title = @album.title
    @subtitle = @album.begin_on.to_s(:number) + '~' + @album.end_on.to_s(:number) + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tags:' + @album.tag_list.join(', ')
    params[:page] = 1 if params[:page].blank?
    params[:per_page] = 30 if params[:per_page].blank?
    case params[:order]
    when "read_level asc" then collection = @album.pictures.sort_by{|item| item.read_level}
    when "read_level desc" then collection = @album.pictures.sort_by{|item| item.read_level}.reverse
    when "comments,asc" then collection = @album.pictures.sort_by{|item| item.comments.size}
    when "comments,desc" then collection = @album.pictures.sort_by{|item| item.comments.size}.reverse
    when "rating_average asc" then collection = @album.pictures.sort_by{|item| item.rating_average}
    when "rating_average desc" then collection = @album.pictures.sort_by{|item| item.rating_average}.reverse
    when "display_order asc" then collection = @album.pictures
    when "display_order desc" then collection = @album.pictures.reverse
    when "top_shown asc" then collection = @album.pictures.sort_by{|item| item.top_shown.to_s}
    when "top_shown desc" then collection = @album.pictures.sort_by{|item| item.top_shown.to_s}.reverse
    else collection = @album.pictures
    end
    @pictures = collection.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def new
  	@album = Album.find(params[:album_id])
  	@sub_title = @album.begin_on.year.to_s + '      ' + @album.title
  	@filenames = get_all_pictures_in_upload_dir
  end
  
  def create
		@album = Album.find(params[:album_id])
		if params[:type] == 'picture'
			if params[:partten] == 'files'
				begin
					params[:filenames].each{|file| @album.contents.create!(:content_type => 'picture', :temp_filename => file)}
          clean_TMP_DIR
				end
			else params[:partten] == 'zip'
			end
			redirect_to admin_album_contents_url
		else params[:type] == 'video'
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
      if Album.find(params[:album_id]).contents.blank?
        redirect_to admin_albums_url
      else
        redirect_to admin_album_contents_url
      end
    end
  end

  def rate
    @content = Content.find(params[:id])
    @content.rate(params[:stars], current_user, params[:dimension])
    id = "ajaxful-rating-" + (!params[:dimension].blank? ? "#{params[:dimension]}-" : "content-#{@content.id}")
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

  private
  
  def get_all_pictures_in_upload_dir(directory = TMP_PIC_DIR)
  	filenames = Array.new
  	Dir.foreach(directory){|xyz|
  		next if ['.', '..'].include?(xyz)
			if File.directory?(directory + xyz)
				filenames.concat(get_all_pictures_in_upload_dir(directory + xyz + '/').map{|item| [xyz+'/'+item[0], xyz+'/'+item[1]]})
			else
				filenames << [xyz, xyz] if File.extname(xyz) =~ /(jpg|jpeg|gif|png|bmp)/i
			end
  	}
  	return filenames
  end

  def clean_TMP_DIR
    Dir.foreach(TMP_PIC_DIR){|xyz|
      next if ['.', '..', '.gitignore'].include?(xyz)
      FileUtils.rm_rf(TMP_PIC_DIR + xyz)
    }
  end
end