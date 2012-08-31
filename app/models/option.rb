class Option < ActiveRecord::Base
  belongs_to :choice
  attr_accessible :blurb, :name, :photo, :position, :website, :twitter, :facebook, :party, :incumbant, :feedback

  has_many :feedback, :conditions => [ "length(comment) > 1 AND length(flag)- length(replace( flag,',','') ) < ? AND approved = ?", 2, true ], :order => ['cached_votes_up - cached_votes_down DESC'], :limit => 3, :readonly => false do
    def page(offset = 0, limit = 10, current_user=nil)
      fb_friends = current_user.nil? ? '' : current_user.fb_friends.split(',')
      fb_friends = '' if fb_friends.empty? || fb_friends.nil?
      all( :joins => :user, :offset => offset, :limit => limit, :conditions => ["fb NOT IN(?)",  fb_friends ] )
    end
    def friends current_user
      fb_friends = current_user.nil? ? '' : current_user.fb_friends.split(',')
      fb_friends = '' if fb_friends.empty? || fb_friends.nil?
      all( :joins => :user, :conditions => ["fb IN(?)", fb_friends ], :limit => nil, :order => "RANDOM()" ) # Returns ALL of your FB friends who've commented on a measure
    end
    def mine me
      all( :conditions => ['user_id = ?', me.id ], :limit => 1 )
    end
    def count_support
      all( :limit => nil ).count
    end
    def count_comments
      all(:limit => nil, :conditions => nil ).count
    end
  end
  
  def all_feedback current_user
    feedback = self.feedback
    unless current_user.nil?
      feedback += self.feedback.friends( current_user )
      feedback += self.feedback.mine( current_user )
    end
    return feedback.uniq.each{ |feedback| feedback.user_flatten }
  end
  


  
  def current_user_is
    return self[:current_user]
  end

  
  # Don't show anyone with two flags or isn't approved
  validates_uniqueness_of :name, :scope => :choice_id
  
end
