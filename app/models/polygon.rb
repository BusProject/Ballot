require 'geo_ruby'

class Polygon < GeoRuby::SimpleFeatures::Polygon
  
  def self.from_array( arrayed_coordinates )
    points = []
    arrayed_coordinates.each do |c|
      points.push GeoRuby::SimpleFeatures::Point.from_x_y(c.first, c.last)
    end
    
    return self::from_points( [points] )
    
  end
  
  def outside_bounding_box?(point)
    bb_point_1, bb_point_2 = bounding_box
    max_x = [bb_point_1.x, bb_point_2.x].max
    max_y = [bb_point_1.y, bb_point_2.y].max
    min_x = [bb_point_1.x, bb_point_2.x].min
    min_y = [bb_point_1.y, bb_point_2.y].min

    point.x < min_x || point.x > max_x || point.y < min_y || point.y > max_y
  end
  
  def contains_point?(x,y)
    point = GeoRuby::SimpleFeatures::Point.from_x_y( x,y )
    return false if outside_bounding_box?(point)
    contains_point = false
    i = -1
    j = self.first.size - 1
    while (i += 1) < self.first.size
      a_point_on_polygon = self.first[i]
      trailing_point_on_polygon = self.first[j]
      
      if point_is_between_the_ys_of_the_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
        if ray_crosses_through_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
          contains_point = !contains_point
        end
      end
      j = i
    end
    return contains_point
  end
  
  private

  def point_is_between_the_ys_of_the_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
    (a_point_on_polygon.y <= point.y && point.y < trailing_point_on_polygon.y) || 
    (trailing_point_on_polygon.y <= point.y && point.y < a_point_on_polygon.y)
  end
  
  def ray_crosses_through_line_segment?(point, a_point_on_polygon, trailing_point_on_polygon)
    (point.x < (trailing_point_on_polygon.x - a_point_on_polygon.x) * (point.y - a_point_on_polygon.y) / 
               (trailing_point_on_polygon.y - a_point_on_polygon.y) + a_point_on_polygon.x)
  end
end
