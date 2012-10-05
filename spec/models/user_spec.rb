require 'spec_helper'

describe User do
  before :each do
    @attributes = {
         :name => 'Test Guy',
         :first_name => 'Test',
         :last_name => 'Guy',
         :authentication_token => 'Bleepbloopbloop',
         :fb => '12345',
         :remember_me => true,
         :email => 'email@example.com',
         :password => Devise.friendly_token[0,20]
       }
    end
     it 'saves a user' do
       user = User.new(@attributes)
       user.save.should == true
     end
     it 'saves a user - changes info and saves a user' do
      @attributes[:profile] = 'different'
      user = User.new(@attributes)
      user.save
      user.profile = 'different'
      user.save.should == true
    end
    it 'saves a user attribute without changing their profile' do
      user = User.new(@attributes)
      user.banned = true
      user.save.should == true
    end
    
end