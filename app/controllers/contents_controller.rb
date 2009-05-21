class ContentsController < ApplicationController
  layout 'simpic'

  before_filter :setup_negative_captcha, :only => [:show, :comment]
  before_filter :update_span_when_navi, :only => [:show, :comment]

  def show
    authority_published = Album.authority(current_read_level).published
    @app_name = APP_NAME
    @copy_year_string = copyright_year_range
    @year_range = authority_published.year_range
    @album_list = authority_published.year(params[:dirname][0..3])
    @active_year = params[:dirname][0..3]
    @album = @album_list.find_by_dirname(params[:dirname])
    @pictures = @album.pictures.authority(current_read_level)
    @content = @pictures.find_by_filename(params[:content_name])
    index = @pictures.index(@content)
    @previous = index == 0 ? nil : @pictures[index-1]
    @next = ((index == @pictures.size-1) ? nil : @pictures[index+1])
  end

  def comment
		@content = Content.find(params[:id])
		if @captcha.valid?
			begin
				new_comment = @content.comments.create!(@captcha.values)
			end
			respond_to do |format|
				format.html {
					redirect_to url_for(:controller => :contents,
		      										:action => :show,
		      										:dirname => @content.album.dirname,
		      										:content_name => @content.filename,
		      										:anchor => "comment_#{@content.comments.first.id}")
		    }
				format.js {
					render :update do |page|
						page.insert_html :bottom, :comments_container, :partial => 'albums/each_comment', :object => new_comment, :locals=>{:each_comment_counter => (@content.comments.size==1 ? 0 : nil)}
						page["old_comments"].show if @content.comments.size==1
						page["new_comment_form"].reset
					end
				}
			end
		end
  end
end