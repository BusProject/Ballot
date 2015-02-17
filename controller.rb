def _mayor_data
    mayors = []

    raw = File.read('mayors.md').split("\n").map{ |c| c.split('|') }
    titles = raw.shift(2).first

    raw.each do |row|
        candidate = {}
        row.each_with_index do |column, index|
            candidate[titles[index].downcase.to_sym] = column if titles[index].length > 1
        end
        mayors.push(candidate)
    end

    mayors.map! do |mayor|
        mayor[:endorsements] = mayor[:endorsements].split(',')
        last_name = mayor[:name].split("\s").last.downcase
        mayor[:photo] = "/images/mayors/#{last_name}.jpg"
        mayor
    end

    titles.shift(3)
    return mayors, titles
end

def _measures_data
    return JSON::parse( File.read('./measures.json'))
end

class Controller

    def index
        @mayors, @questions = _mayor_data
        @measures = _measures_data
    end

    def render path
        ERB.new(File.read(path)).result(binding)
    end
end
