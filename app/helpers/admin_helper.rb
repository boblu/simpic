module AdminHelper
	include Settings
	def js_name
		{'shadowbox' => 0}
	end

	def per_page_list
		[[30, 30], [50, 50], [100, 100]]
	end

	def time_span_list
		[[0, 0], [30, 30], [60, 60], [90, 90], [120, 120]]
	end
end
