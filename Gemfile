source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

gem 'active_model_serializers', '>= 0.10.13'
gem 'acts-as-list'
gem 'aws-sdk-rails', '>= 3.6.1'
gem 'caracal', '>= 1.4.1'
gem 'carrierwave', '>= 2.2.1'
gem 'devise', '>= 4.8.1'
gem 'fog-aws', '>= 3.13.0'
gem 'jquery-rails', '>= 4.4.0'
gem 'jquery-ui-rails', '>= 6.0.1'
gem 'kaminari', '>= 1.2.2'
gem 'mail'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'omniauth-github'
gem 'omniauth_login_dot_gov', git: 'https://github.com/18F/omniauth_login_dot_gov.git', branch: 'main'
gem 'rails', '>= 6.1.4.4'
gem 'pg', '~> 1.3.1'
gem 'puma', '~> 5.6.2'
gem 'rack-cors', '>= 1.1.1', require: 'rack/cors'
gem 'sass-rails', '>= 6.0.0'
gem 'sidekiq'
gem 'uglifier'
gem 'json-jwt'
# Use Redis to cache Touchpoints in all envs
gem 'redis'
gem 'redis-namespace'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'aasm', '~> 5.2.0'
# gem 'webpacker', '~> 5.0'
gem 'whenever', require: false
gem 'logstop'
gem 'paper_trail'
gem 'acts-as-taggable-on', '~> 8.0'
gem "rolify"

group :development, :test do
  gem 'dotenv-rails', '>= 2.7.6'
  gem 'pry'
  gem 'rspec_junit_formatter'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'aasm-diagram'
  gem 'web-console', '>= 4.2.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.36.0'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '>= 6.2.0'
  gem 'rails-controller-testing', '>= 1.0.5'
  gem 'rspec-rails', '>= 5.1.0'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  # gem 'chromedriver-helper'
  gem 'webdrivers', '>= 5.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
