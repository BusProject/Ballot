require 'spec_helper'

describe FeedbackController do

  describe 'UPDATE' do
    it 'if not logged in responds with eror' do
      get 'update'
      json = JSON::parse(response.body)
      json.should == {'success'=>false, 'message'=>'You must sign in to save feedback'} # Doesn't return anything
    end
    
    describe 'if logged in' do
      before :each do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it 'respond with array if nothing posted' do
        get 'update'
        json = JSON::parse(response.body)
        json.should == [] # Doesn't return anything
      end

      it 'respond with failure if no user_id is posted' do
        get 'update', :feedback => [{'option_id' => 1}] 
        json = JSON::parse(response.body)
        json.should == [{'success' =>false, 'obj' => nil, "error"=>{"user_id"=>["Requires a user"] } } ] # Doesn't return anything
      end

      it 'respond with failure if no choice_key is posted' do
        get 'update', :feedback => [{'user_id' => @user.id}] 
        json = JSON::parse(response.body)
        json.should == [{'success' =>false, 'obj' => nil, "error"=>{"option_id"=>["Requires an option"] } } ] # Doesn't return anything
      end

    end
  end


end
