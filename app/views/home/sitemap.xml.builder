xml.instruct!

xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

	@urls.each do |item|
		 xml.url do
			xml.loc item[:url]
			xml.lastmod item[:updated]
			xml.priority item[:priority]
		end
	end
end