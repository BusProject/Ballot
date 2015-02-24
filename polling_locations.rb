require 'open-uri'
require 'json'


def _geolocate_address address
    lookup = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyDHwRG5yky13wkdU04kA_hBgEc-Yg9WhUI&address="

    begin
        data = JSON::parse(open("#{lookup}#{address.gsub(' ','+')}").read)
        lat = data['results'][0]['geometry']['location']['lat']
        lng = data['results'][0]['geometry']['location']['lng']
        return [lat, lng]
    rescue
        return false
    end
end

def _save_data data
    File.open('data/locations.json','w') do |fw|
        fw.write(data.to_json)
    end
end

def proccess_text_file filepath
    polling_locations = File.read(filepath).split("\n")

    polling_locations.map! do |l|
        components = l.split(' ')
        ward = components.shift().to_i
        precinct = components.shift().to_i
        address = "#{ components.join(' ' ) } Chicago IL"

        location = {
            "address" => address,
            "ward" => ward,
            "precinct" => precinct,
        }

        if latlng = _geolocate_address address
            puts "Mapped #{ward}#{precinct}"
            location['latlng'] = latlng
        else
            puts "Failed to map #{ward}-#{precinct}"
        end

        location
    end
    _save_data polling_locations
end

def process_json_file filepath
    polling_locations = JSON::parse File.read(filepath)

    polling_locations.reject{ |l| l['latlng'] }.each do |l|

        if latlng = _geolocate_address l['address']
            puts "Mapped #{ward}#{precinct}"
            l['latlng'] = latlng
        else
            puts "Failed to map #{ward}-#{precinct}"
        end
    end
    _save_data polling_locations
end
