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
         :password => Devise.friendly_token[0,20],
         :profile => 'uppp'
       
       }
    end
     it 'saves a user' do
       user = User.new(@attributes)
       user.save.should == true
     end
     it 'saves a user - changes info and saves a user' do
      user = User.new(@attributes)
      user.save
      user.profile = 'different'
      user.save.should == true
    end
end