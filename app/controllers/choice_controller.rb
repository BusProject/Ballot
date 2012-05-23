class ChoiceController < ApplicationController
  def show
    unless params['q'].nil?
      query = Choice.find_all_by_geography(params['q'].split('|')).to_json(:include => :options)
    else
      query = {'error' => true, 'message' => 'No geometry posted'}.to_json
    end

    render :json => query, :callback => params['callback']
  end
end
