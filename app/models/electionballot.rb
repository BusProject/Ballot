class Electionballot < ActiveRecord::Base
  attr_accessible :electionday, :name, :notes, :open

  validates_presence_of :electionday_id, :name

  belongs_to :electionday

  has_many :choices

end
