require 'json'
require 'erb'

def _mayor_data
    mayors = JSON::parse(File.read('data/mayors.json'))
    titles = mayors.first.keys.reject{ |k| k[-1] != "?" }.map(&:to_s)

    return mayors, titles
end

def _measures_data
    return JSON::parse(File.read('data/measures.json'))
end

class Controller


    def set_meta meta_data={}

        default_description = ("Vote by Tuesday, Feb 24th in the Chicago "+
                               "City Election. Check out our voter guide "+
                               "to see who and what will be on your ballot.")

        default_title = '2015 Chicago Voter Guide'

        default_image = 'images/sharable.png'

        @meta = {
            "title" => meta_data['title'] || default_title,
            "description" => meta_data['description'] || default_description,
            "image" => ("http://www.chicagovoterguide.org/"+
                        "#{meta_data['image'] || default_image}"),
            "url" => ("http://www.chicagovoterguide.org/"+
                      "#{meta_data['url'] || ''}")
        }
        render('_meta.erb')
    end

    def index
        @meta_partial = set_meta
        @mayors, @questions = _mayor_data
        @measures = _measures_data
    end

    def render path
        ERB.new(File.read(path)).result(binding)
    end
end
