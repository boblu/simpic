xml.instruct!
xml.rss "version" => '2.0', "xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
	xml.channel do
    if not @previous.blank? and @previous == true
      xml.atom :link, :rel => 'previous', :href => url_for(:controller => :albums, :action => :cooliris, :album_id => params[:album_id], :id => params[:id].to_i-1, :only_path => false)
		end
    if not @next.blank? and @next == true
      xml.atom :link, :rel => 'next', :href => url_for(:controller => :albums, :action => :cooliris, :album_id => params[:album_id], :id => params[:id].to_i+1, :only_path => false)
		end
    @pictures.each do |picture|
			xml.item do
	      xml.title picture.title
	      xml.guid "img"+picture.id.to_s unless @for_album.blank?
	      xml.media :description, picture.description
        unless @for_album.blank?
          xml.link  url_for(:controller => :contents, :action => :show, :dirname => picture.album.dirname, :content_name => picture.filename, :only_path => false)
        end
        xml.media :thumbnail, :url => @http_header + picture.thumb_url
				xml.media :content, :url => @http_header + picture.normal_url
			end
		end
	end
end
