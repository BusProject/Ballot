load 'controller.rb'

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
    Rake::Task["erb"].invoke(Dir.glob("*.erb"))
end
