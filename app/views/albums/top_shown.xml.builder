xml.instruct!               # <?xml version="1.0" encoding="UTF-8"?>
xml.playlist "xmlns" => "http://xspf.org/ns/0/", "version" => "1" do
	xml.trackList do
		@pictures.each do |picture|
			xml.track do
	      xml.title "ccc"
	      xml.creator "aaa"
	      xml.location picture.medium_url
	      xml.info "bbb"
			end
		end
	end
end
