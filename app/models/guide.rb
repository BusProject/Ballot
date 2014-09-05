class Guide < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :publish, :slug
  validates :slug, uniqueness: {message: 'guide.slug_not_unique'}

end
