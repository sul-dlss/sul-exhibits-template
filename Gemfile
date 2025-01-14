# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.2'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use Puma as the app server
gem 'puma', '~> 6.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler'
  gem 'letter_opener'
  gem 'listen', '~> 3.3'
end

group :development, :test do
  gem 'solr_wrapper'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 2.0'

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i(mri mingw x64_mingw)

  gem 'database_cleaner'

  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false

  gem 'rspec-rails'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'selenium-webdriver', '!= 3.13.0'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :production do
  gem 'mysql2'
  gem 'newrelic_rpm'
end

gem 'config'

gem 'bootstrap', '~> 5.3'
gem 'bootstrap_form', '~> 5.4'
gem 'blacklight', '~> 8.0'
gem 'blacklight-gallery', '~> 4.4'
gem 'blacklight_heatmaps', '~> 1.3.0'
gem 'blacklight-spotlight', '~> 4.4', '>= 4.4.0'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'blacklight_advanced_search'
gem 'blacklight_range_limit', '~> 9.0'
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise-remote-user'
gem 'devise_invitable'
gem 'nokogiri', '>= 1.7.1'
gem 'ruby-oembed'
gem 'okcomputer'
gem 'friendly_id', '~> 5.4'
gem 'sitemap_generator'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro', '~> 7.0'
end

gem 'sidekiq', '~> 7.0'
gem 'dotenv'
gem 'iiif-presentation'
gem 'riiif'
gem 'rsolr'
gem 'faraday'
gem 'purl_fetcher-client', '~> 0.4'
gem 'stanford-mods', '~> 3.0'
gem 'honeybadger'
gem 'slowpoke'
gem 'traject'
gem 'jsonpath'
gem 'bibtex-ruby'
gem 'citeproc-ruby'
gem 'csl-styles'
gem 'acts-as-taggable-on'
gem 'mods_display', '~> 1.6'
gem 'slack-ruby-client'
gem 'blacklight-oembed', '~> 1.0'

# Used for shared reporting https://github.com/sul-dlss/exhibits/issues/2069
gem 'redis', '~> 5.0'
gem 'recaptcha', '~> 5.17.1'

gem 'rack-attack'

gem 'cssbundling-rails', '~> 1.4'
