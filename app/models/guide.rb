class Guide < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :publish

end
