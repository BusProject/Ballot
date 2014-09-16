class Choice < ActiveRecord::Base
  # attr_accessible :contest, :geography, :contest_type, :commentable, :description, :order, :options, :options_attributes, :votes
  validates_presence_of :contest, :geography
  validates_uniqueness_of :contest, :scope => :geography

  has_many :options, :dependent => :destroy, :order => 'position DESC'
  accepts_nested_attributes_for :options, :reject_if => proc { |attrs| attrs['incumbant'] == '0' && false  }

  belongs_to :electionballot

  def to_url
    return self.geography+'/'+self.contest.gsub(' ','_') unless self.geography.nil? || self.contest.nil?
    return ''
  end

  def self.to_json_conditions
    return :include => [ :options ]
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
  def state
    return self.class.states[ self.class.stateAbvs.index( stateAbv ) ]
  end
  def stateAbv
    return geography.split('_').first
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

    if !geography.index('User').nil?
      user = User.find_by_id( geography.split('_')[2] ) || nil
      return [ 'Added', (user.nil? ? '' : 'by '+(user.name || '')),'for',@states[index] ].join(' ')
    end
    return [district,geography+",",@states[index]].join(' ') if district != ''
    return [@states[index],geography].join(' ')
  end
  def self.find_by_state(state,limit=50,offset=0)
      return self.all(
        :conditions => ['geography LIKE ? AND date > ?', state+'%',Date.today],
        :select => 'choices.*',
        :joins => [:electionballot => [:electionday]],
        :order => "contest_type IN('Federal','State','County','Other','Ballot_Statewide','User_Candidate','User_Ballot' ) ASC",
        :limit => limit,
        :offset => offset
      )
    end
    def self.types_by_state(state)
      return self.all(
        :conditions => ['geography LIKE ? AND date > ?', state+'%',Date.today],
        :select => 'DISTINCT( choices.contest_type) ',
        :joins => [:electionballot => [:electionday]]
      ).sort_by{|c| ['Federal','State','County','Other','Ballot_Statewide','User_Candidate','User_Ballot'].index( c.contest_type) }.map{ |c| c.contest_type }
    end
    def self.find_office(geography,contest)
      return Choice.all(
        :limit => 1,
        :joins => [ :electionballot => [ :electionday ] ],
        :conditions => ['geography = ? AND contest = ?',geography,contest],
        :order => 'electiondays.date DESC',
        :select => 'choices.*'
      ).first
    end
  def self.find_by_districts(districts)
    return self.all(
      :select => ' choices.* ',
      :include => [:options],
      :conditions => ['geography IN(?)',districts ],
      :order => "contest_type IN('Federal','State','County','Other','Ballot_Statewide') DESC, geography"
    )

    return future.first.choices.by_district(districts) unless future.first.nil?
    return [] if hidepast # Generally will return empty if no coming elections

    past = Electionday.all( # Returns most recent election for these districts
      :order => 'date ASC',
      :conditions => ['date < ? AND geography IN(?)', Date.parse('2012-11-5'),districts ], #Date.today,
      :joins => [ :electionballots => [ :choices ] ],
      :include => [:choices => [:options => [:feedback => [:user] ] ]],
      :select => 'electiondays.*',
      :limit => 1
    ).first

    return past.choices.by_district(districts)

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
