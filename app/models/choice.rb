class Choice < ActiveRecord::Base
  attr_accessible :contest, :geography, :contest_type, :commentable, :description, :order, :options, :options_attributes
  validates_presence_of :contest, :geography
  validates_uniqueness_of :contest, :scope => :geography
  
  has_many :options, :dependent => :destroy, :readonly => true
  accepts_nested_attributes_for :options, :reject_if => proc { |attrs| attrs['incumbant'] == '0' && false  }
  
  def to_url
    return self.geography+'/'+self.contest.gsub(' ','_') unless self.geography.nil? || self.contest.nil?
    return ''
  end
  
  def prep current_user
    self.options.each do |option| 
      option[:support] = option.feedback.count_support
      option[:comments] = option.feedback.count_comments
      
      option[:faces] = option.feedback.friends_faces( current_user )
      option[:faces] += option.feedback.other_faces( current_user ) if option[:faces].length < 4
      option[:faces] = option[:faces].map{ |f| {:image => f.user.image, :url => f.user.profile } }.shuffle().slice(0,4)
      
      option[:feedbacks] = option.all_feedback(current_user) || []
      
      if self.contest_type.downcase.index('ballot').nil?
        if self.options.select{ |o| o.incumbant? }.length > 0
          option[:option_type] = option.incumbant? ? 'Incumbant' : 'Challenger'
        else
          option[:option_type] = 'Open Seat'
        end
      else
        option[:option_type] = option.type
      end
    end
  end

  def more page, current_user=nil
    feedback = []
    self.options.each do |option|
      feedback += option.feedback.page(page, 10, current_user)
    end
    feedback.each{ |feedback| feedback.user_flatten }
    return feedback
  end

end
