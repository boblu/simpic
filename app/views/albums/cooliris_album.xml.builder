xml.instruct!
xml.rss "version" => '2.0', "xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
	xml.channel do
		xml.atom :link, :rel => 'previous', :href => url_for(:controller => :albums, :action => :cooliris, :album_id => params[:album_id], :id => params[:id].to_i-1, :only_path => false)
		xml.atom :link, :rel => 'next', :href => url_for(:controller => :albums, :action => :cooliris, :album_id => params[:album_id], :id => params[:id].to_i+1, :only_path => false)
		@pictures.each do |picture|
			xml.item do
	      xml.title picture.title
	      xml.guid "img"+picture.id.to_s
	      xml.media :description, picture.description
				xml.media :thumbnail, :url => picture.medium_url
				xml.media :content, :url => picture.normal_url
			end
		end
	end
end
