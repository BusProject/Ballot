class DirtyController < ApplicationController
  def update
    data = params['data'].to_a
    response = []
    data.each do |rep|
      json = rep[1].to_json
      begin
        response.push(  RestClient.post 'http://suctiessawnestoopecteret:iYiPTf7l2Xjq6aqXslDh7hLB@ballot.cloudant.com/feedback/', json, {:content_type => :json} )
      rescue
        response.push( { 'id' => rep[1]['_id'], 'ok' => false, 'message' => 'Already saved' } )
      end

    end

    #response = data
    
    render :json => response
  end
end