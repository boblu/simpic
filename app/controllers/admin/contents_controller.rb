class Admin::ContentsController < ApplicationController
  layout 'admin'
  
  def index
    @album = Album.find(params[:album_id])
    @pictures = @album.pictures
  end
  
  def new
  	@album = Album.find(params[:album_id])
  	@sub_title = @album.begin_on.year.to_s + '      ' + @album.title
  	@filenames = get_all_pictures_in_upload_dir
  end
  
  def create
# Missing template {"commit"=>"add", 
# "filenames"=>["studio2_128388d.jpg", "test/studio2_128398d.jpg", "���̖��ݒ� 1�̃R�s�[.jpg"], 
# "partten"=>"files", "album_id"=>"11", 
# "authenticity_token"=>"rMio1M9RUPPV1T+JKWjcdbCPtFKnOpX2yiIl1hZx+lE=", 
# "action"=>"create", "type"=>"picture", "controller"=>"admin/contents"} in view path app/views
		if params[:type] == 'picture'
			if params[:partten] == 'files'
			
			
			
			
				begin
					params[:filenames].each{|file|
						
					}
				end
			
			
			
			
			
			
			
			else params[:partten] == 'zip'
			
			end
			redirect_to admin_album_contents_url
		else params[:type] == 'video'
		
		end
  end
  
  private
  
  def get_all_pictures_in_upload_dir(directory = TMP_PIC_DIR)
  	filenames = Array.new
  	Dir.foreach(directory){|xyz|
  		next if ['.', '..'].include?(xyz)
			if File.directory?(directory + xyz)
				filenames.concat(get_all_pictures_in_upload_dir(directory + xyz).map{|item| [xyz+'/'+item[0], xyz+'/'+item[1]]})
			else
				filenames << [xyz, xyz] if File.extname(xyz) =~ /(jpg|jpeg|gif|png|bmp)/i
			end
  	}
  	return filenames
  end
end