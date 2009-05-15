xml.instruct!
xml.playlist do
	xml.trackList do
		@pictures.each do |picture|
			xml.track do
	      xml.location picture.normal_url
			end
		end
	end
end
