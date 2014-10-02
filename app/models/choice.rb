class Choice < ActiveRecord::Base
  attr_accessible :contest, :geography, :contest_type, :commentable, :description, :options, :options_attributes, :votes, :description_source, :stop_sync
  validates_presence_of :contest, :geography
  validates_uniqueness_of :external_id, :allow_nil => true

  has_many :options, :dependent => :destroy
  has_many :feedback, :conditions => ['"feedback"."approved" =? ', true] do
    def votes current_user=nil
      user_id = id = current_user.nil? ? 0 : current_user.id
      all( :limit => nil, :conditions => nil, :select => 'DISTINCT("user_id" )', :conditions => ['user_id != ?',user_id] ).count
    end
    def comments current_user=nil
      user_id = id = current_user.nil? ? 0 : current_user.id
      all(:limit => nil, :conditions => 'length(comment) > 1', :select => 'DISTINCT("user_id" )',  :conditions => ['user_id != ?',user_id] ).count
    end
  end

  has_many :users, :through => :feedback
  accepts_nested_attributes_for :options, :reject_if => proc { |attrs| attrs['incumbent'] == '0' && false  }


  def to_url
    return self.geography+'/'+self.contest.gsub(' ','_') unless self.geography.nil? || self.contest.nil?
    return ''
  end

  def self.to_json_conditions
    return :include => [
    :options => {
      :include => [
        :feedbacks => {
            :include => [ :user => { :except => [ :updated_at, :header_content_type, :header_file_name, :header_file_size, :header_updated_at, :email, :location, :address, :match , :remember_me, :password_confirmation, :location, :password, :feedback, :authentication_token, :alerts, :fb_friends, :banned, :deactivated, :admin, :pages, :header_file_name, :header_content_type, :header_file_size, :header_updated_at, :created_at, :url, :match_id, :bg, :secondary, :primary  ] } ],
            :except => [  :approved, :flag]
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
  def self.contest_type_order
    ['Federal','State','Local','Ballot_State', 'Ballot_Local','User_Candidate','User_Ballot']
  end
  def self.contest_type_order_string
    "'"+self.contest_type_order.join("','")+"'"
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
      return [ 'Added', (user.nil? ? '' : 'by '+user.name),'for',@states[index] ].join(' ')
    end
    return [district,geography+",",@states[index]].join(' ') if district != ''
    return [@states[index],geography].join(' ')
  end


  def self.find_by_state(state,limit=50,offset=0)

    pollvault_data = digest_pollvault $pollvault.retrieve_by_state(state)
    pollvault_data = pollvault_data.slice(offset.to_i, limit.to_i) if pollvault_data

    return pollvault_data || self.all(
      :conditions => ['geography LIKE ?', state+'%'],
      :select => 'choices.*',
      :include => [:options => [:feedback]],
      :order => "contest_type IN(#{contest_type_order_string}) ASC",
      :limit => limit,
      :offset => offset
    )
  end
  def self.types_by_state(state)
    return self.all(
      :conditions => ['geography LIKE ?', state+'%'],
      :select => 'DISTINCT( choices.contest_type ) ',
    ).sort_by{|c| [contest_type_order].index( c.contest_type) }.map{ |c| c.contest_type }
  end

  def self.find_office(geography,contest)
    return Choice.all(
      :limit => 1,
      :include => [:options => [:feedback => [:user] ] ],
      :conditions => ['geography = ? AND contest = ?',geography,contest],
      :select => 'choices.*'
    ).first
  end

  def self.find_by_address(address)

    raw = $pollvault.retrieve_by_address(address)
    pollvault_results = digest_pollvault raw

    raw['districts'].map!{ |d| raw['state']+d }

    return pollvault_results || all(
      :select => 'choices.* ',
      :include => [:options],
      :order => "contest_type IN(#{"\'"+contest_type_order.join("\',\'")+"\'"}) ASC",
      :conditions => ['geography IN(?)', raw['districts']],
    )
  end



  def prep current_user
    self[:voted] = self.feedback.votes( current_user )
    self[:commented] = self.feedback.comments( current_user )

    self.options.each do |option|
      option[:support] = option.feedback.count_support
      option[:comments] = option.feedback.count_comments


      option[:faces] = option.feedback.friends_faces( current_user )
      option[:faces] += option.feedback.other_faces( current_user ) if option[:faces].length < 4
      option[:faces] = option[:faces].map{ |f| {:name => f.user.name, :image => f.user.image, :url => f.user.profile } }.shuffle().slice(0,4)

      option[:feedbacks] = option.all_feedback(current_user) || []

      self[:nice_geography] = self.geographyNice(false)
      if self.contest_type.downcase.index('ballot').nil?
        if self.votes.nil? || self.options.length > self.votes
          self[:description] = self.options.map{ |o| o.name }.join(' vs. ')
        else
          self[:description] = self.options.map{ |o| o.name }.to_sentence
        end

        if self.options.select{ |o| o.incumbent? }.length > 0
          option[:option_type] = option.incumbent? ? 'Incumbent' : 'Challenger'
        else
          option[:option_type] = 'Open Seat'
        end
      else
        option[:option_type] = option.type
      end

    end
    self[:nice_geography] = self.geographyNice(false)

    if self.contest_type.downcase.index('ballot').nil?
      names = self.options.map{ |o| o.name }
      self[:description] = self.votes >= self.options.length ?
        names.to_sentence( :words_connector => I18n.t('i18n_toolbox.array.words_connector'), :two_words_connector => I18n.t('i18n_toolbox.array.two_words_connector'), :last_word_connector => I18n.t('i18n_toolbox.array.last_word_connector') ) :
        names.join( I18n.t('i18n_toolbox.array.vs') )
      self[:description] += ' for '+self.votes.to_s+' positions' if self.votes > 1
    end
  end
  # method to add user feedback to profile - even if prepped missed them
  def addUserFeedback user
    feedback = user.feedback.select{ |f| f.choice == self }.first
    unless feedback.nil?
      option = self.options.select{|o| o.id == feedback.option_id }.first
      option[:feedbacks].push( feedback ) if option[:feedbacks].select{ |f| f == feedback }.first.nil? && !option.nil?
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

  def self.digest_pollvault data
    return nil if ! data || data['old']

    choices = []
    state = data['state']

    data['contests'].each do |contest|
      choice = Choice.find_or_initialize_by_external_id(contest['id'])

      choice.contest = contest['name']
      choice.contest_type = contest['electoral_district']['type'].capitalize
      choice.geography = data['state']+contest['electoral_district']['name']

      contest['candidates'].each do |candidate|

        option = Option.find_or_initialize_by_external_id(candidate['id'])

        unless option.stop_sync
          option.name = [candidate['first_name'],candidate['last_name']].join(" ")
          option.photo = candidate['img_lg_url']
          option.party = candidate['party_code']
          option.incumbent = candidate['incumbent']

          option.facebook = candidate['facebook_url']
          option.website = candidate['website_url']
          option.twitter = candidate['twitter_url']


          option.blurb = candidate['bio2'].encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "").force_encoding('UTF-8')
        end

        choice.options.push( option )
      end

      choice.save() unless choice.stop_sync
      choices << choice
    end
    data['questions'].each do |question|
      choice = Choice.find_or_initialize_by_external_id(question['id'])

      choice.contest = question['long_name']
      choice.contest_type = "Ballot_#{question['electoral_district']['type'].capitalize}"
      choice.geography = data['state']+question['electoral_district']['name']

      choice.description = question['summary'].encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "").force_encoding('UTF-8')
      choice.description_source = question['source_url']
      choice.fiscal_impact = question['fiscal_impact'].encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "").force_encoding('UTF-8')

      option = choice.options.find{ |o| o.name == 'Yes' } || Option.new
      option.name = 'Yes'
      choice.options.push( option )

      option = choice.options.find{ |o| o.name == 'No' } ||  Option.new
      option.name = "No"
      choice.options.push( option )

      choice.save() unless choice.stop_sync
      choices << choice
    end

    return choices.sort_by{|c| [contest_type_order].index( c.contest_type) }
  end

end
