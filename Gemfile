source 'http://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'pg'
end

gem 'thin'

group :development, :test do
  gem 'sqlite3'
end

gem 'foreman'

gem 'aws-s3'

gem 'rest-client'
gem 'i18n-js'

gem 'devise', '~> 2.0.0'
gem "omniauth"
gem "omniauth-facebook"

gem "paperclip", "~> 3.0"
gem 'aws-sdk', '~> 1.3.4'
gem 'remotipart', '~> 1.0'

gem 'rmagick'
gem 'fb_graph'

gem 'therubyracer'

gem 'acts_as_votable'

gem 'mobile-fu'

gem 'georuby'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'less-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'
gem 'nokogiri'
gem 'taps'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

#group :test do
  # Pretty printed test output
  #gem 'turn', :require => false
#end

gem "rspec-rails", :group => [:test, :development]

group :test, :development do
  gem "factory_girl_rails"
  gem "guard-rspec"
  gem "growl"
end
