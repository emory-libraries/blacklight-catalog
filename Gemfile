# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '~> 3.1.4'

gem "actionpack-page_caching"
gem 'administrate', '~> 0.17.0'
gem 'blacklight', '~> 7.33'
gem 'blacklight_advanced_search'
gem 'blacklight-marc', '~> 7.2'
gem 'blacklight_range_limit', '~> 7.8'
gem 'bootstrap', '~> 4.0'
gem 'bootstrap-select-rails', '>= 1.13'
gem 'cancancan'
gem 'citeproc-ruby'
gem 'coffee-rails', '~> 4.2'
gem 'csl-styles'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails'
gem 'flipflop', '~> 2.3'
gem 'honeybadger', '~> 4.0'
gem 'inline_svg'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'jwt'
gem 'mysql2', '~> 0.5'
gem 'nokogiri'
gem 'omniauth', '~> 1.9'
gem 'omniauth-shibboleth', '~> 1.3'
gem 'openurl'
gem 'puma', '~> 6.3'
gem 'qa'
gem 'rails', '~> 6.1.7'
gem 'rest-client'
gem 'rsolr', '>= 1.0'
gem 'sass-rails', '~> 5.0'
gem 'secure_headers'
gem 'simple_form' # For database authentication page from Devise
gem 'sqlite3'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false

group :development, :test do
  gem 'bixby'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara', '~> 3.0'
  gem 'coveralls', require: false
  gem 'factory_bot_rails', '~> 4.11.1'
  gem 'faraday', '~> 1.10.3'
  gem 'ffaker'
  gem 'pry' unless ENV['CI']
  gem 'pry-byebug' unless ENV['CI']
  gem 'rails-controller-testing'
  gem 'rspec-its'
  gem 'rspec-mocks'
  gem 'rspec-rails', '~> 5.0'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  gem 'cap-ec2-emory', github: 'curationexperts/cap-ec2'
  gem 'capistrano', '= 3.14.1', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-yarn'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rack-mini-profiler'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'stackprof'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rspec_junit_formatter'
  gem 'webmock'
end
