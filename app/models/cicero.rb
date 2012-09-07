class Cicero
  def self.find(lat, addresses = [] )
    return lat if lat.nil? 


    split = lat.split(',')
    lat = split[0]
    lng = split[1]


    lat = lat.is_a?(Float) ? lat.round(3).to_s : lat.to_f.round(3).to_s
    lng = lng.is_a?(Float) ? lng.round(3).to_s : lng.to_f.round(3).to_s
    
    match = Match.find_by_latlng(lat+','+lng)
    
    if match.nil?
      cicero = Rails.cache.read('cicero')
      
      begin
        if cicero.nil? # no cached token
          cicero = JSON.parse(RestClient.post 'http://cicero.azavea.com/v3.0/token/new.json', {:username => ENV['CICERO'], :password => ENV['CICERO_PASSWORD']})
          Rails.cache.write('cicero',cicero,:expires_in => 24.hours)
        end
    
        if addresses.index('MT').nil?
          legislative = JSON.parse(RestClient.get 'http://cicero.azavea.com/v3.0/legislative_district?type=ALL_2010&lat='+lat+'&lon='+lng+'&token='+cicero['token']+'&user='+cicero['user'].to_s+'&f=json' )
          leg_districts = legislative['response']['results']['districts']
        else
          legislative = JSON.parse(RestClient.get 'http://cicero.azavea.com/v3.0/legislative_district?lat='+lat+'&lon='+lng+'&token='+cicero['token']+'&user='+cicero['user'].to_s+'&f=json' )
          leg_districts = legislative['response']['results']['districts']
        end
        
        # school = JSON.parse(RestClient.get 'http://cicero.azavea.com/v3.0/nonlegislative_district?lat='+lat+'&lon='+lng+'&token='+cicero['token']+'&user='+cicero['user'].to_s+'&f=json&type=SCHOOL' )
        # school_dist = school['response']['results']['districts']
        # Deactivate for now

        all_districts = fix_districts leg_districts # + school_dist
        all_districts+=addresses
        Match.new(:latlng => lat+','+lng, :data =>  all_districts).save
      rescue
        all_districts = addresses
      end

      return all_districts.uniq
    else
      return match.data
    end
  end
  
  def self.district_number district
    return district.length == 1 ? '0'+district : district
  end
  
  def self.fix_districts districts
    districts_fixed = []

    districts.each do |district|
      name = ''
      state = district['state'].nil? ? '' : district['state']
      case district['district_type']
      when 'STATE_LOWER_2010'
        name = 'HD'+district_number(district['district_id'])
      when 'STATE_UPPER_2010'
        name = 'SD'+district_number(district['district_id'])
      when 'NATIONAL_LOWER_2010'
        name = district['district_id'] == state ? '' : 'CD'+district_number(district['district_id'])
      when 'STATE_LOWER'
        name = 'HD'+district_number(district['district_id'])
      when 'STATE_UPPER'
        name = 'SD'+district_number(district['district_id'])
      when 'NATIONAL_LOWER'
        name = district['district_id'] == state ? '' : 'CD'+district_number(district['district_id'])
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