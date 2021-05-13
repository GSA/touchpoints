source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'active_model_serializers', '>= 0.10.12'
gem 'aws-sdk-rails', '>= 3.6.0'
gem 'caracal'
gem 'carrierwave'
gem 'devise', '>= 4.7.3'
gem 'fog-aws'
gem 'jquery-rails', '>= 4.4.0'
gem 'jquery-ui-rails', '>= 6.0.1'
gem 'acts-as-list'
gem 'mail'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'omniauth-github'
gem 'omniauth_login_dot_gov', git: 'https://github.com/18f/omniauth_login_dot_gov.git', branch: 'main'
gem 'rails', '~> 6.1.3'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.3', '>= 5.3.1'
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
gem 'aasm', '~> 4.12'
# gem 'webpacker', '~> 5.0'
gem 'whenever', require: false
gem 'kaminari'


group :development, :test do
  gem 'dotenv-rails', '>= 2.7.6'
  gem 'pry'
  gem 'rspec_junit_formatter'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.7.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.32.2'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '>= 6.1.0'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '>= 4.0.2'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  # gem 'chromedriver-helper'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
