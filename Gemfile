# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.1'

gem 'rails', '~> 7.1.2'

gem 'exception_notification'

gem 'paranoia', '~> 3.0'
# gem 'paper_trail', '~> 15.2'
gem 'lograge', '~> 0.14.0'
gem 'dotenv-rails', '~> 3.1', '>= 3.1.4'
gem "fog-aws"
gem "carrierwave"

gem 'sitemap_generator'

gem 'rack-cors'
gem 'kaminari'
gem 'cancancan'
gem 'devise'
gem 'numbers_and_words', '~> 0.11.12'
# gem 'roo', '~> 2.10'
gem 'jwt'

gem 'unidecoder', '~> 1.1', '>= 1.1.2'

gem 'i18n'

# gem 'sassc-rails'

# gem 'fuzzy_match', '~> 2.1'

gem 'jsbundling-rails'

gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'pg', '~> 1.1'

# gem "debug", require: false

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem 'sprockets-rails', '2.3.3'
gem 'sprockets-rails'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

gem 'cssbundling-rails'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'annotate'
  gem 'debug', platforms: %i[mri windows]
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'foreman'
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end

gem 'dockerfile-rails', '>= 1.5', group: :development

gem 'sentry-ruby', '~> 5.15'

gem 'sentry-rails', '~> 5.15'
