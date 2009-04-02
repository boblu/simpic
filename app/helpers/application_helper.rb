# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def js_name
		[['js0', 0], ['js1', 1], ['js2', 2]]
	end
	
	def authority_name
		[['admin', 0], ['family', 10], ['relative', 20], ['friend', 30], ['reader', 40], ['guest', 50]]
	end
end
