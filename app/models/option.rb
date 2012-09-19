class Option < ActiveRecord::Base
  belongs_to :choice
  attr_accessible :blurb, :name, :photo, :position, :website, :twitter, :facebook, :party, :incumbant, :feedback, :blurb_source

  has_many :feedback, :conditions => [ "length(flag)- length(replace( flag,',','') ) < ? AND approved = ?", 2, true ], :order => ['cached_votes_up - cached_votes_down DESC'], :limit => 4, :readonly => true do
    def page(offset = 0, limit = 10, current_user=nil)
      fb_friends = current_user.nil? || current_user.fb_friends.nil? ? '' : current_user.fb_friends.split(',')
      fb_friends = '' if fb_friends.empty? || fb_friends.nil?
      all( :readonly => true, :joins => :user, :offset => offset, :limit => limit, :conditions => ["length(feedback.comment) > 1 AND fb NOT IN(?)",  fb_friends ] )
    end
    def friends current_user
      fb_friends = current_user.nil? || current_user.fb_friends.nil? ? '' : current_user.fb_friends.split(',')
      fb_friends = '' if fb_friends.empty? || fb_friends.nil?
      all( :readonly => true, :joins => :user, :conditions => ["length(comment) > 1 AND fb IN(?)", fb_friends ], :limit => nil, :order => "RANDOM()" ) # Returns ALL of your FB friends who've commented on a measure
    end
    def friends_faces current_user
      fb_friends = current_user.nil? || current_user.fb_friends.nil? ? '' : current_user.fb_friends.split(',')
      fb_friends = '' if fb_friends.empty? || fb_friends.nil?
      id = current_user.nil? ? '' : current_user.fb
      all( :readonly => true, :joins => :user, :conditions => ["fb IN(?) AND fb != ?", fb_friends, id ], :order => "RANDOM()" , :limit => 10 )
    end
    def other_faces current_user
      fb_friends = current_user.nil? || current_user.fb_friends.nil? ? '' : current_user.fb_friends.split(',')
      fb_friends = '' if fb_friends.empty? || fb_friends.nil?
      id = current_user.nil? ? '' : current_user.fb
      all( :readonly => true, :joins => :user, :conditions => ["fb NOT IN(?) AND fb != ?", fb_friends,id ], :order => "RANDOM()", :limit => 10 )
    end
    def mine me
      all( :readonly => true, :conditions => ['user_id = ?', me.id ], :limit => 1 )
    end
    def count_support
      all( :limit => nil, :conditions => nil ).count
    end
    def count_comments
      all(:limit => nil, :conditions => 'length(comment) > 1' ).count
    end
  end
  
  def type
    return ['yes','support','affirm','for','maintained','approved'].index( self.name.downcase).nil? ? 'no' : 'yes'
  end

  def all_feedback current_user
    feedback = self.feedback.page(0,5)
    unless current_user.nil?
      feedback += self.feedback.friends( current_user )
      feedback += self.feedback.mine( current_user )
    end
    return feedback.uniq
  end
  
  def partySmall
    return '' if self.party.nil?
    return '(D)' unless self.party.index('Democratic').nil?
    return '(R)' unless self.party.index('Republican').nil?
    return '(I)' unless self.party.index('Independent').nil?
    return '(L)' unless self.party.index('Libertarian').nil?
    return '(G)' unless self.party.index('Green').nil?
    return ''
  end


  
  def current_user_is
    return self[:current_user]
  end

  
  validates_uniqueness_of :name, :scope => :choice_id
  
end
