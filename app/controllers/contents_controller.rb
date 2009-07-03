class ContentsController < ApplicationController
  layout 'simpic'

  before_filter :setup_negative_captcha, :only => [:show, :comment]
  before_filter :update_span_when_navi, :only => [:show]
	before_filter :get_authorized_published_albums, :only => [:show]
  before_filter :get_parameters_for_layout, :only => [:show]
  before_filter :get_parameters_for_left_column, :only => [:show]
  before_filter :redirect_to_root_url_if_not_authenticaed, :only => [:show]

  def show
    @pictures = @album.pictures.authority(current_read_level)
    @content = @pictures.find_by_filename(params[:content_name])
    index = @pictures.index(@content)
    @previous = (index == 0 ? nil : @pictures[index-1])
    @next = ((index == @pictures.size-1) ? nil : @pictures[index+1])
  end

  def comment
		@content = Content.find(params[:id])
		if @captcha.valid?
			begin
				new_comment = @content.comments.create!(@captcha.values)
			end
			respond_to do |format|
				format.js {
					render :update do |page|
						page.insert_html :bottom, :comment_container, :partial => 'albums/each_comment', :object => new_comment, :locals=>{:each_comment_counter => (@content.comments.size==1 ? 0 : nil)}
						page["old_comments"].show if @content.comments.size==1
            page.replace_html "comment_num", :inline => @content.comments.size.to_s
						page["new_comment_form"].reset
					end
				}
			end
		end
  end
end