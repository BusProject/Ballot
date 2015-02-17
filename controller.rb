require 'json'
require 'erb'

def _mayor_data
    mayors = JSON::parse(File.read('./mayors.json'))
    titles = mayors.first.keys.reject{ |k| k[-1] != "?" }.map(&:to_s)

    return mayors, titles
end

def _measures_data
    return JSON::parse(File.read('./measures.json'))
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
