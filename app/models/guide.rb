class Guide < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :publish, :slug
  validates :slug, uniqueness: {message: 'guide.slug_not_unique'}
  has_many :blocks

  def self.find_all_by_geography state
	self.find(
		:all,
		:joins => :blocks,
		:conditions => ["blocks.geography is ?", state],
		:limit => 5,
	)
  end
end
