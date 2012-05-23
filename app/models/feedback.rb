class Feedback < ActiveRecord::Base
  self.table_name = 'feedback'

  attr_accessible :option, :comment, :support, :user
  validates_presence_of :user_id, :message => 'Requires a user'
  validates_presence_of :option_id, :message => 'Requires an option'

  validates_uniqueness_of :option_id, :scope => :user_id, :message => 'only one comment and vote per person per option'

  belongs_to :user
  belongs_to :option
end
