class Cicero
  def self.find(lat, lng = nil )
    return lat if lat.nil? 

    if lng.nil?
      split = lat.split(',')
      lat = split[0]
      lng = split[1]
    end

    lat = lat.is_a?(Float) ? lat.round(3).to_s : lat.to_f.round(3).to_s
    lng = lng.is_a?(Float) ? lng.round(3).to_s : lng.to_f.round(3).to_s
    
    match = Match.find_by_latlng(lat+lng)
    
    if match.nil?
      cicero = Rails.cache.read('cicero')
    
      if cicero.nil? # no cached token
        cicero = JSON.parse(RestClient.post 'http://cicero.azavea.com/v3.0/token/new.json', {:username => 'ballot', :password => 'votefucker'})
        Rails.cache.write('cicero',cicero,:expires_in => 24.hours)
      end
    
      legislative = JSON.parse(RestClient.get 'http://cicero.azavea.com/v3.0/legislative_district?lat='+lat+'&lon='+lng+'&token='+cicero['token']+'&user='+cicero['user'].to_s+'&f=json' )
      leg_districts = legislative['response']['results']['districts']
    
      #school = JSON.parse(RestClient.get 'http://cicero.azavea.com/v3.0/nonlegislative_district?lat='+lat+'&lon='+lng+'&token='+cicero['token']+'&user='+cicero['user'].to_s+'&f=json&type=SCHOOL' )
      #school_dist = school['response']['results']['districts']
      # Deactivate for now

      all_districts = fix_districts leg_districts #+school_dist
      Match.new(:latlng => lat+lng, :data =>  all_districts).save

      return all_districts
    else
      return match.data
    end
  end
  
  def self.fix_districts districts
    districts_fixed = []

    districts.each do |district|
      name = ''
      state = district['state'].nil? ? '' : district['state']
      case district['district_type']
      when 'STATE_LOWER'
        name = 'HD'+district['district_id']
      when 'STATE_UPPER'
        name = 'SD'+district['district_id']
      when 'NATIONAL_LOWER'
        name = district['district_id'] == state ? '' : 'CD'+district['district_id']
      when 'NATIONAL_EXEC'
        name = 'Prez'
      when 'NATIONAL_UPPER'
        name = ''
      when 'SCHOOL'
        name = 'SCHOOL'+district['label']
      when 'STATE_EXEC'
        name = ''
      else
        name = district['city']
      end
      districts_fixed.push(state+name)
    end
    return districts_fixed.uniq
  end

end