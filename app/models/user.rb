class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :image, :location, :name, :url, :first_name, :last_name, :feedback
  # attr_accessible :title, :body
  has_many :feedback
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = self.find_by_email(data.email)
      user
    else # Create a user with a stub password. 
      self.create!(
        :email => data.email, 
        :password => Devise.friendly_token[0,20], 
        :image => access_token.info.image, 
        :location => access_token.info.location, 
        :url => data.link, 
        :name => data.name, 
        :first_name => data.first_name,
        :last_name => data.last_name
      ) 
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
    end
  end  

end
