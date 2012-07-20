class Option < ActiveRecord::Base
  belongs_to :choice
  attr_accessible :blurb, :name, :photo, :position

  has_many :feedback, :conditions => [ "length(flag)- length(replace( flag,',','') ) <= ? AND approved = ?", 2, true]
  # Don't show anyone with two flags or isn't approved
  validates_uniqueness_of :name, :scope => :choice_id
end
