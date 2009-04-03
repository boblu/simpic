class Admin::ContentsController < ApplicationController
  layout 'admin'
  
  def index
    @album = Album.find(params[:album_id])
    @pictures = @album.pictures
  end
end