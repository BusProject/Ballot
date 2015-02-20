require "gridle"

guard 'rake', :task => 'erb' do
    watch(%r{^.+.html.erb$})
end

guard 'rake', :task => 'all' do
    watch(%r{controller.rb|Rakefile|data/*.json})
end

guard 'sass', :input => 'stylesheets', :compass => true

guard 'livereload' do
    watch(%r{.+\.(css|js|html)})
end
