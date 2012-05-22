# FUNCTION: dirty_map(45.5212158,-122.66414989999998)
# TO DO: Write up as a single function
# Write step function to cover an area

# From GOOGLE
# "northeast" : { "lat" : 90.0,"lng" : 180.0},
# "southwest" : {"lat" : -90.0,"lng" : -180.0}
            
def dirty_map( lat, lng)
  require 'rest-client'
  require 'json'

  latlng = lat.to_s+','+lng.to_s
  matcher = { 'from' => [{'lat' => lat, 'lng' => lng, 'time' => Time.new }]}
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
  matcher['from'][0]['address'] = result['formatted_address']

  result['address_components'].each do |address|
    if address['types'].include?('locality')
      matcher['city'] = [address['long_name']]
    end
    if address['types'].include?('administrative_area_level_1')
      matcher['state'] = [address['short_name']]
    end
    if address['types'].include?('administrative_area_level_2')
      matcher['county'] = [address['long_name']]
    end
    if address['types'].include?('neighborhood')
      matcher['county'] = [address['long_name']]
    end
    if address['types'].include?('route')
      matcher['county'] = [address['long_name']]
    end
    if address['types'].include?('street_number')
      matcher['county'] = [address['long_name']]
    end
  end

  couch_response = []



  reps.each do |rep|
    rep['_id'] = rep['district']
    rep['matcher'] = {}
    rep['matcher']['city'] = matcher['city'].dup
    rep['matcher']['county'] = matcher['county'].dup
    rep['matcher']['from'] = matcher['from'].dup
    rep['matcher']['state'] = matcher['state'].dup


    couch_store = JSON.parse(RestClient.get 'http://suctiessawnestoopecteret:iYiPTf7l2Xjq6aqXslDh7hLB@ballot.cloudant.com/feedback/_design/reps/_view/cities', :params => {'key' => '"'+rep['_id']+'"'} )

    unless couch_store['rows'] == []
      stored_rep = couch_store['rows'][0]['value']

      rep['_rev'] = stored_rep['rev']

      ['state','city','county','route','street_number','neighborhood'].each do |name|
        rep['matcher'][name].concat(stored_rep['matcher'][name])
        rep['matcher'][name].uniq!
      end

      # rep['matcher']['from'].concat(stored_rep['matcher']['from'])
      # rep['matcher']['county'].uniq!

    end

    json = rep.to_json
    begin
      couch_response.push(  RestClient.post 'http://suctiessawnestoopecteret:iYiPTf7l2Xjq6aqXslDh7hLB@ballot.cloudant.com/feedback/', json, {:content_type => :json} )
    rescue
      couch_response.push( { 'id' => rep['_id'], 'ok' => false, 'message' => 'Already saved' } )
    end
  end
  return couch_response
end


#puts dirty_map(45.5212158,-122.66414989999998)
