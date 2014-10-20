class Block < ActiveRecord::Base
  belongs_to :guide
  belongs_to :option
  belongs_to :user_option
<<<<<<< Updated upstream
  attr_accessible :content, :title, :block_order, :geography
=======
  attr_accessible :content, :title, :block_order
>>>>>>> Stashed changes
end
