class Feedback < ActiveRecord::Base
  attr_accessible :choice_key, :comment, :support, :user
  validates_presence_of :user_id, :message => 'Requires a user'
  validates_presence_of :choice_key, :message => 'Requires a choice'
end
