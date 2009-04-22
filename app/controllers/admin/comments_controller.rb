class Admin::CommentsController < ApplicationController
  layout 'admin'
  
  def index
    params[:page] = 1 if params[:page].blank?
    params[:per_page] = 30 if params[:per_page].blank?
  	if params[:album_id].blank? and params[:content_id].blank?
  		@comments = Comment.paginate(:page => params[:page], :per_page => params[:per_page])
  		@title = 'All comments'
  		@subtitle = nil
  		params[:album_id] = nil
  		params[:content_id] = nil
  	else
  		@album = Album.find(params[:album_id])
  		@title = 'Comments'
  		case params[:content_id]
  		when 'all'
  			@subtitle = 'All picture in ' + @album.title
  			@comments = @album.contents.inject([]){|comments_array, content| comments_array.concat(content.comments)}.sort_by{|comment| comment.created_at}
  			@comments = @comments.paginate(:page => params[:page], :per_page => params[:per_page])
  		when nil
  			@subtitle = @album.title
  			@comments = @album.comments.paginate(:page => params[:page], :per_page => params[:per_page])
  		else
	  		@content = Content.find(params[:content_id])
  			if @content.title.blank?
  				@subtitle = 'picture in ' + @album.title
  			else
  				@subtitle = @content.title + ' in ' + @album.title
  			end
  			@comments = @content.comments.paginate(:page => params[:page], :per_page => params[:per_page])
  		end
  	end
  end
  
  def batch_delete
    begin
      Comment.transaction do
        params[:selected_id].each{|id| Comment.find(id).destroy}
      end
    end
    redirect_to admin_comments_url(:album_id => params[:album_id], :content_id => params[:content_id])
  end
end