class Match < ActiveRecord::Base
  attr_accessible :data, :latlng
  validates_uniqueness_of :latlng
  serialize :data
end
