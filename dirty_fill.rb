puts dirty_map(45.5212158,-122.66414989999998)
# TO DO: Write up as a single function
# Write step function to cover an area

def dirty_map( lat, lng)
  require 'rest-client'
  require 'json'

  latlng = lat.to_s+','+lng.to_s
  matcher = { 'from' => {'lat' => lat, 'lng' => lng }}
  reps = []

  # Sunlight matching to congressional
  data = 'apikey=8fb5671bbea849e0b8f34d622a93b05a&longitude='+lng.to_s+'&latitude='+lat.to_s
  response = JSON.parse(RestClient.get 'http://services.sunlightlabs.com/api/legislators.allForLatLong.json?'+data)

  response['response']['legislators'].each do |leg|
    rep = {}

    legislator = leg['legislator'] 

    title = legislator['chamber'] != 'senate' ? 'Representative' : 'Senator'
    rank = legislator['chamber'] != 'senate' ? '' : legislator['district'].split(' ')[0].capitalize()+' '
    district_label = legislator['chamber'] != 'senate' ? 'CD'+legislator['district'] : rank.strip()+'S'
  
    rep['title'] = rank+title
    rep['district'] = legislator['state']+district_label
  
    reps.push(rep)
  end


  # Sunlight matching to state
  data = 'apikey=8fb5671bbea849e0b8f34d622a93b05a&long='+lng.to_s+'&lat='+lat.to_s
  response = JSON.parse(RestClient.get 'http://openstates.org/api/v1/legislators/geo/?'+data)

  response.each do |legislator|
    rep = {}

    title = legislator['chamber'] == 'lower' ? 'Representative' : 'Senator'
    dist = legislator['chamber'] == 'lower' ? 'HD' : 'SD'
  
    rep['title'] = 'State '+title
    rep['district'] = legislator['state'].upcase()+dist+legislator['roles'][0]['district']
  
    reps.push(rep)
  end



  # Google Matching
  response = JSON.parse(RestClient.get 'http://maps.googleapis.com/maps/api/geocode/json?latlng='+latlng+'&sensor=false')
  result = response['results'][0]
  matcher['from']['address'] = result['formatted_address']

  result['address_components'].each do |address|
    if address['types'].include?('locality')
      matcher['city'] = address['long_name']
    end
    if address['types'].include?('administrative_area_level_1')
      matcher['state'] = address['short_name']
    end
    if address['types'].include?('administrative_area_level_2')
      matcher['county'] = address['long_name']
    end
  end

  couch_response = []
  reps.each do |rep|
    rep['_id'] = rep['district']
    rep['matcher'] = matcher
  
    json = rep.to_json
    begin
      couch_response.push(  RestClient.post 'http://suctiessawnestoopecteret:iYiPTf7l2Xjq6aqXslDh7hLB@ballot.cloudant.com/feedback/', json, {:content_type => :json} )
    rescue
      couch_response.push( { 'id' => rep['_id'], 'ok' => false, 'message' => 'Already saved' } )
    end
  end
  return couch_response
end

