class Electionday < ActiveRecord::Base
  attr_accessible :date, :election_type, :id, :name
  
  validates_presence_of :date, :election_type, :name
  
  has_many :electionballots
  has_many :choices, :through => :electionballots do
    def by_district districts
      all( :conditions => ['geography IN(?)',districts], :include =>  [:options => [:feedback => [:user] ] ]  )
    end
  end

end
