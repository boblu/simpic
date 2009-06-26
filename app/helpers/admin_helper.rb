module AdminHelper
	def js_name
		{'Shadowbox' => 0, 'JW image rotator' => 1, 'Embedded cooliris' => 2, 'Simple Viewer' => 3, 'NoobSlide' => 4}
	end

	def per_page_list
		[[30, 30], [50, 50], [100, 100]]
	end

	def time_span_list
		{"Unlimited" => 0, "30 m" => 1800, "60 m" => 3600, "90 m" => 5400, "120 m" => 7200}
	end
	
	def admin_album_contents_path_with_session_information
    session_key = ActionController::Base.session_options[:key]
    admin_album_contents_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token, 'type' => 'picture', "pattern" => 'remote')
  end
end
