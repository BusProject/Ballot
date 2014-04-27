class Match < ActiveRecord::Base
  validates_uniqueness_of :latlng
  serialize :data
end
