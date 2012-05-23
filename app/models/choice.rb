class Choice < ActiveRecord::Base
  attr_accessible :contest, :geography, :contest_type, :commentable, :description, :order, :options
  validates_presence_of :contest, :geography
  validates_uniqueness_of :contest, :scope => :geography
  
  has_many :options
end
