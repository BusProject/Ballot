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
        get 'update', :feedback => [{'choice_key' => 'dickface'}] 
        json = JSON::parse(response.body)
        json.should == [{'success' =>false, 'obj' => nil, "error"=>{"user_id"=>["Requires a user"] } } ] # Doesn't return anything
      end

      it 'respond with failure if no choice_key is posted' do
        get 'update', :feedback => [{'user_id' => @user.id}] 
        json = JSON::parse(response.body)
        json.should == [{'success' =>false, 'obj' => nil, "error"=>{"choice_key"=>["Requires a choice"] } } ] # Doesn't return anything
      end

    end
  end

  describe 'SHOW' do
    before :each do
      ['Bob','Jim','Frank'].each do |name|
        FactoryGirl.create(:feedback, choice_key: name )
      end
    end
    
    it 'shows all the of the feedback if no names are posted' do
      get 'show'
      response.body.should == Feedback.all.to_json
    end
    it 'filters names if name is posted' do
      get 'show', :name => 'Bob'
      response.body.should == Feedback.find_all_by_choice_key('Bob').to_json
    end
    it 'filters by many names if comma listed is posted' do
      get 'show', :name => 'Bob,Frank'
      response.body.should == Feedback.find_all_by_choice_key(['Bob','Frank']).to_json
    end
  end

  
end
