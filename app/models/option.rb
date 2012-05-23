class Option < ActiveRecord::Base
  belongs_to :choice
  attr_accessible :blurb, :name, :photo, :position
  has_many :feedback
end
