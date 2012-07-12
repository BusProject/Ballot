source 'http://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'sqlite3'
end

gem 'rest-client'

gem 'devise', '~> 2.0.0'
gem "omniauth"
gem "omniauth-facebook"

gem 'rmagick'
gem 'fb_graph'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

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
group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem 'launchy'
  gem 'database_cleaner'
  gem "guard-rspec"
  gem 'growl'
  gem 'jasmine'
  gem 'jasmine-headless-webkit'
  gem 'guard-jasmine-headless-webkit'
  gem 'guard-rails-assets'
end