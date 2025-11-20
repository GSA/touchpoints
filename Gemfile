source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.7'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma'

gem 'importmap-rails', '>= 2.2.0'

# Hotwire"s SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '>= 2.0.14'

# Hotwire"s modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.12'

gem 'active_model_serializers'
gem 'acts-as-list'
gem 'aws-actionmailer-ses'
gem 'aws-sdk-rails', '>= 3.8.0'
gem 'aws-sdk-s3'
gem 'carrierwave', '>= 2.2.1'
gem 'csv'
gem 'devise', '>= 4.8.1'
gem 'fog-aws', '>= 3.15.0'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'kramdown'
gem 'mail'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'omniauth-github'
gem 'omniauth_login_dot_gov', git: 'https://github.com/18F/omniauth_login_dot_gov.git', branch: 'main'
gem 'omniauth-rails_csrf_protection'
gem 'rack-attack'
gem 'rack-cors', '>= 3.0.0', require: 'rack/cors'
# Use Redis to cache Touchpoints in all envs
gem 'aasm'
gem 'acts-as-taggable-on'
gem 'json-jwt'
gem 'logstop'
gem 'paper_trail'
gem 'redis-client'
gem 'redis-namespace'
gem 'rolify'
gem 'sidekiq', '>= 8.0.4'

# Rust integration for high-performance widget rendering
gem 'rutie', '~> 0.0.4'

group :development, :test do
  gem 'dotenv'
  gem 'pry'
end

group :development, :staging, :test do
  gem 'faker'
end

group :development do
  gem 'aasm-diagram'
  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit'
  gem 'listen'
  gem 'rails-erd'
  gem 'rubocop-rails', '>= 2.32.0'
  gem 'rubocop-rspec'
  gem 'ruby-lsp', require: false
  gem 'web-console'
end

group :test do
  gem 'axe-core-rspec'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '>= 6.5.0'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '>= 8.0.1'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
