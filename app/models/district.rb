class District < ActiveRecord::Base
  attr_accessible :name, :shape, :geography 
  
  def self.geography_match districts, latlng
    
    districts = self.where('geography IN( ? )',districts)
    results = []
    lat,lng = latlng.split(',').map(&:to_f)

    districts.each do |district|
      match = district.locate(lat,lng)
      results.push( [district.geography,match].join(' ') ) if match
    end
    
    return results
  end
  
  def locate lat,lng
    shape = JSON::parse(self.shape)
    features = shape["features"]
    
    features.each do |feature|
      polygon = Polygon.from_array( feature['geometry']['coordinates'][0] )
      return feature['properties']['Name'] if polygon.contains_point?(lng,lat)
    end
    
    return false
  end
  
end
