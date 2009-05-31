xml.instruct!
	if not @latest.blank?
		xml.instruct! 'xml-stylesheet', {:href=>'/stylesheets/rss.css', :type=>'text/css'}
		xml.rss "version" => '2.0' do
			xml.channel do
				xml.title @app_name + " latest albums"
				xml.link @domain_and_port + "/albums.rss"
				@latest.each do |album|
					xml.item do
						xml.title album.title
						xml.link @domain_and_port + url_for(:controller => :albums, :action => :show, :dirname => album.dirname)
						xml.description content_tag(:p, "#{album.begin_on.to_s} ~ #{album.end_on.to_s}") + content_tag(:p, album.description) + content_tag(:p){
							album.pictures.authority(current_read_level).covered(:limit => 5).inject(""){|html_string, picture|
								html_string << "<img src='#{@domain_and_port + picture.thumb_url}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
							}
						}
					end
				end
			end
		end
	elsif @album.blank? or @album.appearance == 1
		xml.playlist do
			xml.trackList do
				@pictures.each do |picture|
					xml.track do
			      xml.location picture.normal_url
					end
				end
			end
		end
	elsif @album.appearance == 3
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