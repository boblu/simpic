xml.instruct!
xml.playlist do
	xml.trackList do
		@pictures.each do |picture|
			xml.track do
	      xml.title picture.title
	      xml.location picture.medium_url
	      xml.description picture.description
			end
		end
	end
end
