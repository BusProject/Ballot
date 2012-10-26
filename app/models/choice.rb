class Choice < ActiveRecord::Base
  attr_accessible :contest, :geography, :contest_type, :commentable, :description, :order, :options, :options_attributes, :votes
  validates_presence_of :contest, :geography
  validates_uniqueness_of :contest, :scope => :geography
  
  has_many :options, :dependent => :destroy, :order => 'position DESC'
  has_many :feedback, :conditions => ['"feedback"."approved" =? ', true] do
    def votes
      all( :select => 'DISTINCT(user_id)' ).count
    end
    def comments
      all( :select => 'DISTINCT(user_id)', :conditions => ['comment != ? AND comment != ?',nil,''] ).count
    end
    
  end
  has_many :users, :through => :feedback
  accepts_nested_attributes_for :options, :reject_if => proc { |attrs| attrs['incumbant'] == '0' && false  }
  
  
  def to_url
    return self.geography+'/'+self.contest.gsub(' ','_') unless self.geography.nil? || self.contest.nil?
    return ''
  end
  
  def self.to_json_conditions
    return :include => [ 
    :options => { 
      :include => [
        :feedbacks => {
            :include => [ :user => { :except => [ :updated_at, :header_content_type, :header_file_name, :header_file_size, :header_updated_at, :email, :id, :location, :address, :match , :remember_me, :password_confirmation, :location, :password, :feedback, :authentication_token, :alerts, :fb_friends, :banned, :deactivated, :admin, :pages, :header_file_name, :header_content_type, :header_file_size, :header_updated_at, :created_at, :url, :match_id, :bg, :secondary, :primary  ] } ]
          }
        ]
      }
    ]
  end
  
  def fullDelete
    self.options.each{ |o| o.delete } unless self.options.nil?
    self.delete
  end
  
  def self.states 
    return ["The United States of America","Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming","Washington DC"]
  end
  def self.stateAbvs
    return ["Prez","AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY","DC"]
  end
  
  def geographyNice( stateOnly=true)

    @stateAbvs = Choice.stateAbvs
    @states = Choice.states
    
    index = @stateAbvs.index(self.geography.slice(0,2))
    index = 0 if self.geography == 'Prez'
    return self.geography if index.nil?
    return @states[index] if stateOnly || self.geography.length == 2 || self.geography == 'Prez'
    
    geography = self.geography.slice(2,self.geography.length)
    geography = 'State House District' if geography.slice(0,2) == 'HD'
    geography = 'State Senate District' if geography.slice(0,2) == 'SD'
    geography = 'Congressional District' if geography.slice(0,2) == 'CD'

    geography = 'State Legislative District' if @states[index] == 'Nebraska' && geography == 'State Senate District' # Nebraska only has one legislative chamber

    
    
    district = self.geography.slice(4,self.geography.length) if geography != self.geography.slice(2,self.geography.length)
    district = district.to_i.ordinalize if !district.nil? && district.to_i.to_s == district.gsub('0','')
    
    return [ 'Added by', User.find( geography.split('_')[2] ).name,'for',@states[index] ].join(' ') if !geography.index('User').nil?
    
    return [district,geography+",",@states[index]].join(' ') if district != ''
    return [@states[index],geography].join(' ')
  end
  
  def self.find_by_districts(districts)
    return self.all( 
      :select => ' choices.* ', 
      :include => [:options],  
      :conditions => ['geography IN(?)',districts ], 
      :order => "contest_type IN('Federal','State','County','Other','Ballot_Statewide') DESC, geography"
    )
  end

  def prep current_user
    self.options.each do |option| 
      option[:support] = option.feedback.count_support
      option[:comments] = option.feedback.count_comments
      
      option[:faces] = option.feedback.friends_faces( current_user )
      option[:faces] += option.feedback.other_faces( current_user ) if option[:faces].length < 4
      option[:faces] = option[:faces].map{ |f| {:name => f.user.name, :image => f.user.image, :url => f.user.profile } }.shuffle().slice(0,4)
      
      option[:feedbacks] = option.all_feedback(current_user) || []
      
      self[:nice_geography] = self.geographyNice(false)
      if self.contest_type.downcase.index('ballot').nil?
        self[:description] = self.options.map{ |o| o.name }.join(' vs. ')
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
  # method to add user feedback to profile - even if prepped missed them
  def addUserFeedback user  
    feedback = user.feedback.select{ |f| f.choice == self }.first
    option = self.options.select{|o| o.id == feedback.option_id }.first
    option[:feedbacks].push( feedback ) if option[:feedbacks].select{ |f| f == feedback }.first.nil?
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
