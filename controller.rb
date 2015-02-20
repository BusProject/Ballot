require 'json'
require 'erb'

def mayor_data
    mayors = JSON::parse(File.read('data/mayors.json'))
    titles = mayors.first.keys.reject{ |k| k[-1] != "?" }.map(&:to_s)

    return mayors, titles
end

def measures_data
    return JSON::parse(File.read('data/measures.json'))
end
def _get_ordinal n
    n = n.to_i
    s = ["th","st","nd","rd"]
    v = n % 100
    "#{n}#{(s[(v-20)%10]||s[v]||s[0])}"
end

class Controller

    def set_meta meta_data=nil
        meta_data ||= {}

        default_description = ("Vote by Tuesday, Feb 24th in the Chicago "+
                               "City Election. Check out our voter guide "+
                               "to see who and what will be on your ballot.")

        default_title = '2015 Chicago Voter Guide'

        default_image = 'http://www.chicagovoterguide.org/images/sharable.png'

        @meta = {
            "title" => meta_data['title'] || default_title,
            "description" => meta_data['description'] || default_description,
            "image" => ("#{meta_data['image'] || default_image}"),
            "url" => ("#{meta_data['url'] || 'http://www.chicagovoterguide.org'}")
        }
        render('_meta.erb')
    end
    def filename
        @filename
    end

    def index
        @meta_partial = set_meta
        @mayors, @questions = mayor_data
        @measures = measures_data
    end
    def mayor mayor
        base = "http://www.chicagovoterguide.org"

        @anchor = mayor["name"].downcase.gsub(' ','-').gsub(/[^a-zA-Z0-9\-]/,'')
        @filename = "mayor/#{@anchor}"
        @meta_partial = set_meta({
            'url' => "#{base}/#{@filename}",
            'image' => "#{base}#{mayor['photo']}",
            'title' => "Vote for #{mayor['name']} for Mayor of Chicago",
            'description' => ("I'm supporting #{mayor['name']} for Mayor of "+
                              "Chicago - and so is "+
                              "#{mayor['endorsements'].join(', ')}"),
        })
    end
    def measure measure
        base = "http://www.chicagovoterguide.org"

        @anchor =  (measure['title'].downcase.gsub(' ','-')
                    .gsub(/[^a-zA-Z0-9\-]/,''))
        @filename = "measure/#{measure['choice']}-#{@anchor}"
        @meta_partial = set_meta({
            'url' => "#{base}/#{@filename}",
            'image' => "#{base}/images/#{measure['choice']}.png",
            'title' => "Vote #{measure['choice']} for #{measure['title']}",
            'description' => ("I'm supporting #{measure['choice']} on "
                              "#{measure['title']} Chicago - and so is "+
                              "#{measure['endorsements'].join(', ')}"),
        })
    end
    def alderman alderman
        base = "http://www.chicagovoterguide.org"

        name = [alderman['first'], alderman['last']].join(' ')
        link = name.downcase.gsub(' ','-').gsub(/[^a-zA-Z0-9\-]/,'')
        office = "#{_get_ordinal(alderman['ward'])} Ward Alderman"
        @anchor =  "@#{alderman['ward']}"
        @filename = "alderman/#{alderman['ward']}-#{link}"

        @meta_partial = set_meta({
            'url' => "#{base}/#{@filename}",
            'image' => "#{base}#{alderman['photo']}",
            'title' => "Vote #{name} for #{office}",
            'description' => "Vote #{name} for #{office} - and you should too",
        })
    end


    def render path
        ERB.new(File.read(path)).result(binding)
    end
end
