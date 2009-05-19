xml.instruct!
case @album.appearance
when 1
	xml.playlist do
		xml.trackList do
			@pictures.each do |picture|
				xml.track do
		      xml.location picture.normal_url
				end
			end
		end
	end
when 3
	xml.simpleviewergallery :maxImageWidth => "640",
													:maxImageHeight => "560",
													:textColor => "0x333333",
													:frameColor => "0x999999",
													:frameWidth => "0",
													:stagePadding => "0",
													:navPadding => "5",
													:thumbnailColumns => "8",
													:thumbnailRows => "2",
													:navPosition => "bottom",
													:vAlign => "top",
													:hAlign => "center",
													:title => "",
													:enableRightClickOpen => "false",
													:backgroundImagePath => "",
													:imagePath => (request.protocol + request.host_with_port + File.dirname(@pictures[0].normal_url) + '/'),
													:thumbPath => (request.protocol + request.host_with_port + File.dirname(@pictures[0].thumb_url) + '/') do
		@pictures.each do |picture|
			xml.image do
				xml.filename picture.filename
				xml.caption "<font face='Times' size='15' color='#EE0000'>" + link_to("Comment and Rate!", url_for(:controller => :contents, :action => :show, :dirname => @album.dirname, :content_name => picture.filename)) + "</font>&nbsp;&nbsp;&nbsp;&nbsp;" + (picture.title || '')
			end
		end											
	end
end