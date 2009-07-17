# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_root_path(locale)
    locale == @app_setting["default_locale"].to_sym ? '/' : '/' + locale.to_s
  end
  
	def shadowbox_script(html_string = "")
		html_string << javascript_include_tag("/effects/shadowbox-build-3.0b/shadowbox")+ "\n"
		html_string << stylesheet_link_tag('/effects/shadowbox-build-3.0b/shadowbox')+ "\n"
		html_string << "<script type='text/javascript'>Shadowbox.init({slideshowDelay: 0, overlayOpacity: 0.9});</script>"
	end

	def cooliris_feed
		temp_url = url_for(:controller => :albums, :action => :cooliris, :album_id => @album.id, :id => (params[:page] || '1'), :only_path => false)
		content_tag(:link, nil, :ref => "alternate", :href => temp_url, :type => "application/rss+xml")
	end

	def authenticate_header
		if not logged_in?
			render :partial => "albums/login_form"
		elsif current_read_level == 0
			link_to(t('admin'), admin_albums_path) + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + link_to(t('logout'), logout_path)
		else
			t('welcome') + "&nbsp;" + current_user.name + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + link_to(t('logout'), logout_path)
		end
	end

	def render_news(class_name, albums)
		first_row = content_tag(:tr) do
			content_tag(:td, nil, :class => "corner top_left") + content_tag(:td, nil, :class => "fillin") + content_tag(:td, nil, :class => "corner top_right")
		end
		news_content = content_tag(:h4, t(class_name)) + content_tag(:ul) do
			albums.inject("") do |html_string, album|
				html_string << content_tag(:li, link_to(album.title, url_for(:controller => :albums, :action => :show, :dirname => album.dirname))) + "\n"
			end
		end
		middle_row = content_tag(:tr) do
			content_tag(:td, nil, :class => "fillin") + content_tag(:td, news_content, :class => "fillin content") + content_tag(:td, nil, :class => "fillin")
		end
		last_row = content_tag(:tr) do
			content_tag(:td, nil, :class => "corner bottom_left") + content_tag(:td, nil, :class => "fillin") + content_tag(:td, nil, :class => "corner bottom_right")
		end
		content_tag(:table, first_row + middle_row + last_row, :class => "rounded news #{class_name}",  :border => "0",  :cellspacing => "0",  :cellpadding => "0")
	end

	
	def top_page_year_range(year_range)
		first_row = content_tag(:tr) do
			content_tag(:td, nil, :class => "corner top_left") + content_tag(:td, nil, :class => "fillin") + content_tag(:td, nil, :class => "corner top_right")
		end
		news_content = content_tag(:h4, t('more')) + content_tag(:table) do
			content_tag(:tr) do
				year_range.inject("") do |html_string, year|
					html_string << content_tag(:td, link_to(year, url_for(:controller => :albums, :action => :show, :year => year)))
					html_string << '</tr><tr>' if year_range.index(year) != 0 and year_range.index(year) % 2 == 0
					html_string
				end
			end
		end
		middle_row = content_tag(:tr) do
			content_tag(:td, nil, :class => "fillin") + content_tag(:td, news_content, :class => "fillin content") + content_tag(:td, nil, :class => "fillin")
		end
		last_row = content_tag(:tr) do
			content_tag(:td, nil, :class => "corner bottom_left") + content_tag(:td, nil, :class => "fillin") + content_tag(:td, nil, :class => "corner bottom_right")
		end
		content_tag(:table, first_row + middle_row + last_row, :class => "rounded top_year_list",  :border => "0",  :cellspacing => "0",  :cellpadding => "0")
	end

	def recent_comments(comments, html_string = "")
		comments.each do |comment|
			if comment.commentable_type == "Album"
				link_string = content_tag(:b, comment.name) + " #{t('commented')} "  + %Q|"#{truncate(comment.content, :length => 80)}"|
				html_string << content_tag(:li, link_to(link_string, url_for(:controller => :albums, :action => :show, :dirname => comment.commentable.dirname, :anchor => "comment_#{comment.id}")))
			else
				link_string = content_tag(:b, comment.name) + " #{t('commented')} "  + %Q|"#{truncate(comment.content, :length => 80)}"|
				html_string << content_tag(:li, link_to(link_string, url_for(:controller => :contents, :action => :show, :dirname => comment.commentable.album.dirname, :content_name => comment.commentable.filename, :anchor => "comment_#{comment.id}")))
			end
		end
		content_tag(:ul, html_string)
	end
end
