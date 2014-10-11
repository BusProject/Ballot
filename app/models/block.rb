class Block < ActiveRecord::Base
  belongs_to :guide
  belongs_to :option
  belongs_to :user_option
  attr_accessible :content, :title, :order
end
