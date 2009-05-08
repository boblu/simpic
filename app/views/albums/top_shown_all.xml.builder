xml.instruct!
xml.rss "version" => '2.0', "xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
	xml.channel do
		@pictures.each do |picture|
			xml.item do
	      xml.title picture.title
	      xml.media :description, picture.description
				xml.media :thumbnail, :url => picture.thumb_url
				xml.media :content, :url => picture.normal_url
			end
		end
	end
end
