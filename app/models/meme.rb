class Meme < ActiveRecord::Base
  attr_accessible :image, :quote, :feedback
  
  
  has_attached_file :photo,
    :storage => :s3,
    :bucket => 'ballot',
    :s3_credentials => {
      :access_key_id => ENV['AWS3'],
      :secret_access_key => ENV['AWS3_SECRET']
    }
    
  belongs_to :feedback
  has_one :user, :through => :feedback
  has_one :option, :through => :feedback
end
