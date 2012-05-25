class ChoiceController < ApplicationController
  def show
    
    districts = params['q'].nil? ? Cicero.find(params['l']) : params['q'].split('|')
    
    unless districts.nil?
      
      choices = Choice.find_all_by_geography( districts )
      
      unless params['group'].nil?
        results = []
        districts.each do |district|
         results.push( { 'geography' => district, 'choices' => choices.select{ |choice| choice.geography == district } } )
        end
      else
        results = choices
      end

      query = results.to_json(:include => [:options => {:include => :feedback}] )

    else
      query = {'error' => true, 'message' => 'Nothing useful was posted'}.to_json
    end
    
    render :json => query, :callback => params['callback']
  end
end
