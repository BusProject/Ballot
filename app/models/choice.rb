class Choice < ActiveRecord::Base
  attr_accessible :contest, :geography, :contest_type, :commentable, :description, :order, :options, :options_attributes
  validates_presence_of :contest, :geography
  validates_uniqueness_of :contest, :scope => :geography
  
  has_many :options, :dependent => :destroy
  accepts_nested_attributes_for :options, :reject_if => proc { |attrs| attrs['incumbant'] == '0' && false  }
  
  def to_url
    return self.geography+'/'+self.contest.gsub(' ','_') unless self.geography.nil? || self.contest.nil?
    return ''
  end
  
  def prep current_user
    self.options.each do |option| 
      option[:support] = option.feedback.count_support
      option[:comments] = option.feedback.count_comments
      option.feedback = option.all_feedback(current_user)
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
