require 'geo_ruby'

class Polygon < GeoRuby::SimpleFeatures::Polygon

  attr_accessor :holes

  def self.from_array( arrayed_coordinates )
    
    if arrayed_coordinates[0][0].class != Float
      main_polygon = arrayed_coordinates.shift()
      holes = arrayed_coordinates unless arrayed_coordinates.nil?
      arrayed_coordinates = main_polygon
    end

    new_polygon = self::from_points( array_to_points arrayed_coordinates )
    new_polygon.holes = []

    holes.each do |hole|
      new_polygon.holes.push( self::from_points( array_to_points hole ) )
    end

    return new_polygon
  end

  def self.array_to_points(arrayed_coordinates) # Creates array of points from an array
    points = []
    arrayed_coordinates.each do |c|
      points.push GeoRuby::SimpleFeatures::Point.from_x_y(c[0], c[1])
    end
    return [points]
  end

  
  def is_inside?(x,y)
    if self.contains_point?(x,y) # Does contian the point - yayyy
      @holes.each do |hole| # Is the point in one of the holes? 
        return false if hole.contains_point?(x,y) # Nooo it is in the hole and not in the district
      end
      return true # Wow ok - not in the hole. Great we're good
    else
      return false
    end
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

