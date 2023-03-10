source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

# caching
gem 'actionpack-action_caching'

gem "audited", "~> 5.0"

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
# snowflake integration
if ENV['CLOUD_PLATFORM']!='heroku'
  gem 'ruby-odbc' 
  gem 'sequel'
end

# for jobs
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sidekiq-failures'

# gem for pdf generation
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'

# for tempate mailing
gem 'bootstrap-email', '~> 1.0'

# Rack::Cors provides support for Cross-Origin Resource Sharing (CORS) 
# for Rack compatible web applications.
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
# pagination library 
gem 'will_paginate', '~> 3.3'
# to perform job daily
gem 'whenever', require: false

#for Loads environment variables
gem 'dotenv-rails', '~> 2.8', '>= 2.8.1'
gem 'noticed'

group :development, :test do
  gem 'bullet'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
  gem 'rswag-specs'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end

group :development do
  # Preview email in the default browser instead of sending it.
  gem 'letter_opener'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'active_record_query_trace'
end
