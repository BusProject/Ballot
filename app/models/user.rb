class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
    :image, :location, :name, :url, :first_name, :last_name, :feedback, 
    :admin, :authentication_token, :guide_name, :fb, :profile,
    :fb_friends, :description, :alerts, :pages, :profile,
    :primary, :secondary, :bg, :header, :match, :address

  acts_as_voter
  
  # attr_accessible :title, :body
  has_many :feedback do
    def most_recent
      all( :order => 'updated_at DESC', :limit => 1).first
    end
    def rating
      all( :select => 'SUM( "feedback"."cached_votes_up" - "feedback"."cached_votes_down") AS rating' ).first.rating
    end
  end
  has_many :memes, :through => :feedback
  has_many :options, :through => :feedback
  has_many :choices, :through => :options

  
  serialize :pages
  
  belongs_to :match
  
  # Method determining what's turned into JSON
  def to_public(json=true)
    hidden = [ :updated_at, :email, :location, :address, :match , :remember_me, :password_confirmation, :location, :password, :feedback, :authentication_token, :alerts, :fb_friends, :banned, :deactivated, :admin, :pages, :header_file_name, :header_content_type, :header_file_size, :header_updated_at, :created_at, :url, :match_id ]
    return self.to_json( :except => hidden ) if json

    about = {}
    attributes = User.attr_accessible[:default].to_a.concat([:id]).select{|a| hidden.index(a.to_sym).nil? }.map{ |a| about[a] = self[a] }
    return about
    
  end
  
  def recommenders
    return User.find_by_sql( ['SELECT "users".* FROM "votes" INNER JOIN "users" on "votes"."voter_id" = "users"."id" WHERE "votes"."votable_id" IN(?) AND "votes"."votable_type" = "Feedback"', self.feedback.map{ |f| f.id } ]).uniq
  end
  
  # Profile and URL related methods
  after_initialize :set_profile
  validate :check_profile
  before_save :fix_profile
  
  # Method for generating a link to the profile
  def set_profile
      if self.has_attribute? 'profile'
        if self.profile.nil? || self.profile.empty?
          self[:profile] = '/'+self.to_url unless self.to_url.nil?
        else
          self[:profile] = '/'+self.profile
        end
      end
  end
  
  # Method to see if profile name is free
  def check_profile
    if !self.profile.nil? && (self.profile || '' ).gsub('/','') != (self.to_url || '' ).gsub('/','')
      self.profile = self.profile.gsub('/','')
      id = self.profile.to_i(16).to_s(16) == self.profile ? self.profile.to_i(16).to_s(10).to_i(2).to_s(10).to_i(10) : 0
      safe = true 
      if id != 0 # Future proofing all URL names for our first 10^20th users
        safe = id > 10e20
      end
      notstate =  Choice.stateAbvs.concat( 'users|admin|lookup|api|feedback|source|search|sitemap|m|about|how-to|guides|2012|2011|2010|2009|2008|resources'.split('|') ).index( self.profile )
      safe = notstate.nil? && safe
      errors.add( :profile, 'is not unique' ) unless User.where('(id = ? OR profile = ?)  AND id != ?',id,self.profile,self.id).empty? && safe
    else
      self.profile = nil
    end
  end
  
  def fix_profile
    self.profile = self.profile.gsub('/','') unless self.profile.nil?
  end
  
  def to_url ( full = false)
    unless self.new_record? # A simple way of creating funky looking URLs out of User IDs
      url = self.id.to_s(2).to_i.to_s(16)
      url = ENV['BASE']+'/'+url if full && !ENV['BASE'].nil?
    else
      url = nil
    end

    return url
  end
  
  def self.active
    return self.find_by_sql(['SELECT "users".* FROM "feedback" INNER JOIN "users" ON "users"."id" = "feedback"."user_id" WHERE ("feedback"."approved" = ? AND "users"."banned" != ? AND "users"."deactivated" != ?  ) ORDER BY "feedback"."updated_at"',true,true,true])
  end

  def self.by_state(state=nil,limit=5)
    if state.nil?
      return self.all( 
      :select => 'DISTINCT( substr("choices"."geography",0,3)) as geography, "users".* ',
      :include => [:feedback],
      :joins => :choices, 
      :conditions => ['"choices"."geography" != ?','Prez'], 
      :order => '"geography" ASC' ).group_by{|c| c.geography } 
    else
      return self.all( 
        :group => ' "users"."id" ',
        :select => '"users".*,  SUM( "feedback"."cached_votes_up" - "feedback"."cached_votes_down"  ) AS rating  ', 
        :joins => :choices, 
        :conditions =>['"choices"."geography" LIKE ?',state+'%'], 
        :order => 'rating DESC',
        :limit => limit || 5
      )
    end
  end
  
  def self.top_25
    return User.all( 
      :limit => 25,
      :select => '"users".*, SUM( "feedback"."cached_votes_up" - "feedback"."cached_votes_down") AS rating',
      :group => "users.id",
      :order => 'rating DESC', 
      :joins => :feedback 
    )
  end
  
  # Header image handling
  
  if Rails.env == "production"
    has_attached_file :header,
      :styles => {:header => '860x180#'},
      :storage => :s3, 
      :s3_credentials => {
        :bucket            => 'the-ballot',
        :access_key_id     => ENV['AWS3'],
        :secret_access_key => ENV['AWS3_SECERET']
      }
  else
    has_attached_file :header,
      :styles => {:header => '860x180#'}
  end
  
  before_post_process :resize_images
  before_save :check_size
  
  def image?
    header_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
  end

  def resize_images
    return false unless image?
  end
  
  def check_size
    return unless image?
    tempfile = header.queued_for_write[:original]
    unless tempfile.nil?
      dimensions = Paperclip::Geometry.from_file( tempfile )
      return dimensions.height >= 150 && dimensions.width >= 720
    end
  end
  
  
  
  # Method to deactivate self
  def deactivate mode = false
    success = true
    self.feedback.each do |feedback|
      feedback.approved = mode
      success = feedback.save && success
    end
    success = self.save && success
    return success
  end
  
  # Method to determine if a user can comment
  def commentable?
    return !self.banned? && !self.deactivated?
  end
  

  # Method for authentication after facebook auth
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    attributes = {
        :image => access_token.info.image, 
        :location => access_token.info.location, 
        :url => data.link,
        :name => data.name,
        :first_name => data.first_name,
        :last_name => data.last_name,
        :authentication_token => access_token.credentials.token,
        :fb => data.id,
        :remember_me => true
      }
    if user = self.find_by_email(data.email)
      user.update_attributes( attributes )
      user
    else # Create a user with a stub password. 
      attributes[:email] = data.email
      attributes[:password] = Devise.friendly_token[0,20]
      self.create!( attributes )
    end
  end
  
  # Method for authentication as a page by a user
  def self.find_with_fb_id(fb_id, attributes)
    if user = self.find_by_fb(fb_id)
      return user
    else
      graphInfo = JSON::parse(RestClient.get 'https://graph.facebook.com/'+fb_id)
      attributes = {
          :image => attributes[:image], 
          :location => graphInfo['location'].nil? ? '' : graphInfo['location']['city']+', '+graphInfo['location']['state'],
          :url => graphInfo['link'],
          :name => attributes[:name],
          :first_name => '',
          :last_name => attributes[:name],
          :authentication_token => attributes[:authentication_token],
          :fb => fb_id,
          :email => graphInfo['username'].nil? ? fb_id+'@facebook.com' : graphInfo['username']+'@facebook.com',
          :password => Devise.friendly_token[0,20]
        }
      return self.create!( attributes )
    end

  end
  
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
    end
  end
  
  def refresh_token( current_token )
    auth = FbGraph::Auth.new( ENV['FACEBOOK'], ENV['FACEBOOK_SECRET']) # attempting to deal with expired FB cookies
    auth.exchange_token! current_token
    self.authentication_token = auth.access_token
    self.save
  end
  

  

end