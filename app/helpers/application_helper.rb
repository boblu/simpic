# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def js_name
		[['js0', 0], ['js1', 1], ['js2', 2]]
	end
	
	def authority_name
		[['admin', 0], ['family', 10], ['relative', 20], ['friend', 30], ['reader', 40], ['guest', 50]]
	end

	def authority_list
		authority_name.inject({}){|temp, item| temp[item[1]] = item[0]; temp}
	end
	
	def per_page_list
		[[30, 30], [50, 50], [100, 100]]
	end

	def time_span_list
		[[0, 0], [30, 30], [60, 60], [90, 90], [120, 120]]
	end
end
