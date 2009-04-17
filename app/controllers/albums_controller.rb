class AlbumsController < ApplicationController
  layout 'simpic', :except => [:top, :top_shown]

	def top
		@app_name = APP_NAME
		unless User.first
			redirect_to init_admin_users_url
			return
		end
	end
	
	def top_shown
		@pictures = Content.all(:conditions => {:content_type => 'picture',
																						:top_shown => true}, :order => 'rating_average desc')
 		render :action => "top_shown.xml.builder"
	end
end
