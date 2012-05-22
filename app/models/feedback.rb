class Feedback < ActiveRecord::Base
  attr_accessible :option, :comment, :support, :user
  validates_presence_of :user_id, :message => 'Requires a user'
  validates_presence_of :option_id, :message => 'Requires an option'
  validates_presence_of :choice_key, :message => 'Requires a choice'

  validates_uniqueness_of :options_id, :scope => :user_id, :message => 'only one comment and vote per person per option'

  belongs_to :user
  belongs_to :option
end
