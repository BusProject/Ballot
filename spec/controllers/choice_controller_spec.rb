require 'spec_helper'

describe ChoiceController do
  describe 'SHOW' do

    it 'responds with JSON error if nothing posted' do
      get 'show'
      json = JSON::parse(response.body)
      json.should == {'error' => true, 'message' => 'No geometry posted'}
    end
    
    describe 'basic query of choices' do
      before :each do
        @choices = []
        5.times do
          @choices.push(FactoryGirl.create(:choice))
        end
      end

      it 'responds with the choice data for the queried geographies' do
        get 'show', :q => @choices[1].geography+'|'+@choices[2].geography
        response.body == Choice.find(@choices[1].id,@choices[2].id).to_json
      end
    end
    
    describe 'query of choices with options' do
      before :each do
        @choices = []

        5.times do
          choice = FactoryGirl.create(:choice)
          2.times do
            FactoryGirl.create(:option, :choice => choice)
          end
          @choices.push(choice)
        end
      end
      
      it 'responds with the option data for the queried geographies' do
        get 'show', :q => @choices[4].geography+'|'+@choices[2].geography
        json = JSON::parse(response.body)

        json[0]['options'].should.to_json == Choice.find(@choices[2].id).options.to_json
        json[1]['options'].should.to_json == Choice.find(@choices[4].id).options.to_json
      end
      
    end

  end
end
