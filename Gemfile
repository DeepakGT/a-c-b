source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem "aws-sdk-s3", require: false
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
# access countries
gem 'countries'
# Simple, multi-client and secure token-based authentication for Rails.
gem 'devise_token_auth'
gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
# Create JSON structures via a Builder-style DSL
gem 'jbuilder', '~> 2.11', '>= 2.11.2'
# the database for Active Record
gem 'pg', '~> 1.2.3'
# authorization
gem 'pundit'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.4'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'


# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem

gem 'rspec-rails'

# Api documentation
gem 'rswag'
# Static code analyzer and code formatter
gem 'rubocop', '~> 1.22', require: false
# Rack::Cors provides support for Cross-Origin Resource Sharing (CORS) 
# for Rack compatible web applications.
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
# pagination library 
gem 'will_paginate', '~> 3.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rswag-specs'
  gem 'pry'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 5.0'
end

group :development do
  # Preview email in the default browser instead of sending it.
  gem 'letter_opener'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
