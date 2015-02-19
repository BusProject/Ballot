require 'csv'
require 'open-uri'
require 'twitter'


alderpeople = JSON::parse(File.read('data/alderpeople.json'))


def make_filename person
    "#{person['ward']}-#{person['first']}-#{person['last']}"
end

def grab_photo(person, path)
    return path if path.index('images/alderpeople')

    ext = path.split('.').last
    ext = 'jpg' if ext.length > 4

    filename = make_filename person
    filename = "images/alderpeople/#{filename}.#{ext}"
    begin
        open(path) do |f|
            File.open(filename,"wb") do |file|
                file.puts f.read
            end
        end
        return filename
    rescue OpenURI::HTTPError => error
    end
    return false
end

# Clean the data
alderpeople.each do |person|
    person.each do |k, v|
        person[k] = v.strip if v
    end
end

# Check if photo exists
Dir.glob('images/alderpeople/*').each do |file|
    filename = file.split('.').first.split('/').last
    person = alderpeople.find{ |p| make_filename(p)== filename }
    person['photo'] = file if person
end

# Grab Photos from photo url
alderpeople.reject{ |p| p['photo'].nil? }.each do |person|
    photo = grab_photo person, person['photo']
    person['photo'] = photo ? photo : nil
end

# I've expired these
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "EGYNtJkjYbESmbUPGBHZCA"
  config.consumer_secret     = "TXlCXQfIYu2aLiUgo2GfmAj78DNt6JVQmxjhOM"
  config.access_token        = "14759621-lwHJpacKaBNy7ha5tRJccHAVjYoW6EOV54F5uiddw"
  config.access_token_secret = "xqTzCIGK4DVgW1J9sUQLqPuF5NCMnLGOpMEengNjsQ"
end

begin
    # Get photo from twitter
    alderpeople.reject{ |p| p['twitter'].nil? || p['photo'] }.each do |person|
        begin
            user = client.user( person['twitter'].split('/').last )
            photo = grab_photo person, user.profile_image_url.to_s.gsub('_normal','')
            person['photo'] = photo if photo
        rescue Twitter::Error::NotFound => error
            person['twitter'] = nil
        end
    end
rescue Twitter::Error::TooManyRequests => error
end

# Get photo from tribune website
alderpeople.reject{ |p| p['photo'] }.each do |person|
    first = person['first'].split(' ').first
    last = person['last'].split(' ').last
    photo = ("http://elections.chicagotribune.com/static/electioncenter2/"+
             "IL_edboard"+"/#{first}-#{last}.jpg".downcase)
    photo = grab_photo person, photo
    person['photo'] = photo if photo
end


CSV.open("data/alderpeople.csv", "wb") do |csv|
  csv << alderpeople.first.keys
  alderpeople.each do |hash|
    csv << hash.values
  end
end

File.open('data/alderpeople.json','wb') do |fl|
    fl.write(alderpeople.to_json)
end

