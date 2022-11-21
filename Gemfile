source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.3"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire"s SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire"s modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails", "~> 2.1"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.12"

gem "brakeman"
gem "bundler-audit"
gem "rubocop-rails"
gem "rubocop-rspec"
gem 'active_model_serializers', '>= 0.10.13'
gem 'acts-as-list'
gem 'aws-sdk-rails', '>= 3.6.3'
gem 'caracal', '>= 1.4.1'
gem 'carrierwave', '>= 2.2.1'
gem 'devise', '>= 4.8.1'
gem 'fog-aws', '>= 3.15.0'
gem "jbuilder" # Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jquery-rails', '>= 4.5.0'
gem 'kaminari', '>= 1.2.2'
gem 'kramdown'
gem 'mail'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'omniauth-github'
gem 'omniauth_login_dot_gov', git: 'https://github.com/18F/omniauth_login_dot_gov.git', branch: 'main'
gem 'rack-cors', '>= 1.1.1', require: 'rack/cors'
# Use Redis to cache Touchpoints in all envs
gem "redis", "~> 4.6"
gem 'redis-namespace'
gem 'sass-rails', '>= 6.0.0'
gem 'sidekiq'
gem 'json-jwt'
gem 'aasm'
gem 'whenever', require: false
gem 'logstop'
gem 'paper_trail'
gem 'acts-as-taggable-on'
gem "rolify"

group :development, :test do
  gem 'dotenv-rails', '>= 2.8.1'
  gem 'pry'
  gem 'rspec_junit_formatter'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'aasm-diagram'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rails-erd'
  gem 'web-console', '>= 4.2.0'
  gem 'bullet'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.37.1'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '>= 6.2.0'
  gem 'rails-controller-testing', '>= 1.0.5'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  # gem 'chromedriver-helper'
  gem 'webdrivers', '>= 5.1.0'
end
