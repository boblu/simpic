module AdminHelper
	include Settings
	def js_name
		{'Shadowbox' => 0, 'JW image rotator' => 1, 'Embedded cooliris' => 2}
	end

	def per_page_list
		[[30, 30], [50, 50], [100, 100]]
	end

	def time_span_list
		{"None" => 0, "30 m" => 30, "60 m" => 60, "90 m" => 90, "120 m" => 120}
	end
end
