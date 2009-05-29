class Admin::SettingsController < ApplicationController
  layout 'admin'

  before_filter :authorize_admin
  
  def edit
    @settings = App.first.settings
  end

  def update
  	if request.post?
  		begin
	  		@app = App.first
	  		@app.settings["app_name"] = params[:app_name]
	  		@app.save!
			end
  	end
  	redirect_to admin_albums_url 
  end
end