class AlbumsController < ApplicationController
  layout 'simpic'

	def top
		unless User.first
			redirect_to init_admin_users_url
			return
		end
	end
end
