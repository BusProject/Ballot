require 'csv'
require 'webrick'

load 'controller.rb'

task :serve do
    port = ARGV[1] || 8080
    server = WEBrick::HTTPServer.new(:Port => port, :DocumentRoot => Dir.pwd)
    trap('INT') { server.shutdown }
    server.start
end

task :mayors do
    mayors, _ = _mayor_data

    markdown = [[]]

    mayors.first.keys.each do |key|
        markdown.first.push(key.to_s.capitalize)
    end

    markdown.push(Array.new(mayors.first.keys.length,'---'))
    mayors.each do |mayor|
        markdown.push([])
        mayor.each do |k,v|
            if k == "photo"
                markdown.last.push("![](#{v})")
            else
                markdown.last.push(v.respond_to?('join') ? v.join(',') : v)
            end
        end
    end

    File.open('mayors.md','w') do |fl|
        fl.write(markdown.map{ |r| "|#{r.join('|')}|" }.join("\n"))
    end
end

task :alderpeople do
    alderpeople = []
    CSV.foreach("data/alderpeople.csv",
                :headers => true) do |row|
         alderpeople.push Hash[row.headers.map(&:downcase).zip(row.fields.map)]
    end
    File.open('data/alderpeople.json','w') do |fl|
        fl.write(alderpeople.to_json)
    end
end

task :erb, :paths do |t,args|
    """
    Rebuild HTML pages.
    """

    controller = Controller.new()

    args.paths.each do |path|
        new_file = path.gsub('.erb','')
        function_name = path.split('.').first

        puts "Rewriting #{new_file}"

        File.open(new_file, 'w') do |fl|
            controller.send(function_name) if controller.respond_to?(function_name)
            fl.write(controller.render(path))
        end
    end
end

task :all do
    """
    Rebuild all the HTML pages.
    """
    Rake::Task["erb"].invoke(Dir.glob("*.html.erb"))
end
