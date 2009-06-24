xml.instruct!
	case @xml_type
	when "site_rss_feed"
		xml.rss "version" => '2.0' do
			xml.channel do
				xml.title @app_name + " latest albums"
				xml.link @http_header + "/albums.rss"
				@latest.each do |album|
					xml.item do
						xml.title album.title
						xml.link @http_header + url_for(:controller => :albums, :action => :show, :dirname => album.dirname)
						xml.description content_tag(:p, "#{album.begin_on.to_s} ~ #{album.end_on.to_s}") + content_tag(:p, album.description) + content_tag(:p){
							album.pictures.authority(current_read_level).covered[0..4].inject(""){|html_string, picture|
								html_string << "<img src='#{@http_header + picture.thumb_url}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
							}
						}
					end
				end
			end
		end
	when "top_shown_new", "album_jw_image_rotator"
		xml.playlist do
			xml.trackList do
				@pictures.each do |picture|
					xml.track do
			      xml.location picture.normal_url
					end
				end
			end
		end
	when "album_simple_viewer"
		xml.simpleviewergallery :maxImageWidth => "640",			:maxImageHeight => "560",			:textColor => "0x333333",
														:frameColor => "0x999999",		:frameWidth => "0",						:stagePadding => "0",
														:navPadding => "5",						:thumbnailColumns => "8",			:thumbnailRows => "2",
														:navPosition => "bottom",			:vAlign => "top",							:hAlign => "center",
														:title => "",									:enableRightClickOpen => "false",		:backgroundImagePath => "",
														:imagePath => @imagePath,			:thumbPath => @thumbPath do
			@pictures.each do |picture|
				xml.image do
					xml.filename picture.filename
					xml.caption "<font face='Times' size='15' color='#EE0000'>" + link_to("Comment and Rate this picture!", url_for(:controller => :contents, :action => :show, :dirname => @album.dirname, :content_name => picture.filename)) + "</font>&nbsp;&nbsp;&nbsp;&nbsp;" + (picture.title || '')
				end
			end											
		end
	end