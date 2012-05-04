class Feedback < ActiveRecord::Base
  attr_accessible :choice_key, :comment, :support, :user

end
