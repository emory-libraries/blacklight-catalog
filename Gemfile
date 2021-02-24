# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '>=2.5.0'

gem 'blacklight', '7.4.1'
gem 'blacklight-marc', '>= 7.0.0.rc1'
gem 'blacklight_range_limit'
gem 'bootstrap', '~> 4.0'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'mysql2', '~> 0.5'
gem 'nokogiri'
gem 'omniauth-shibboleth', '~> 1.3'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.7'
gem 'rest-client'
gem 'rsolr', '>= 1.0'
gem 'sass-rails', '~> 5.0'
gem 'secure_headers'
gem 'sqlite3'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'bixby'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara', '>= 2.15'
  gem 'coveralls', require: false
  gem 'factory_bot_rails', '~> 4.11.1'
  gem 'ffaker'
  gem 'pry' unless ENV['CI']
  gem 'pry-byebug' unless ENV['CI']
  gem 'rails-controller-testing'
  gem 'rspec-its'
  gem 'rspec-rails', '~> 3.5'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '>= 0.3'
  gem 'webdrivers', '~> 3.0'
end

group :development do
  gem 'cap-ec2-emory', github: 'emory-libraries/cap-ec2'
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
  gem 'xray-rails'
end

group :test do
  gem 'rspec_junit_formatter'
  gem 'webmock'
end
