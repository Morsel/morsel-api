source 'https://rubygems.org'

ruby '2.1.4'

gem 'unicorn', '~> 4.8.3'
gem 'rails', '~> 4.1.9'
gem 'pg'
gem 'pg_search', '~> 0.7.8'
gem 'oink', '~> 0.10.1'

gem 'active_model_serializers', '~> 0.8.2'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'addressable', '~> 2.3.6'
gem 'authority', '~> 2.9.0'
gem 'bitly', '~> 0.10.1'
gem 'bootstrap-sass', '>= 3.0.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'carrierwave', '~> 0.10.0'
gem 'carrierwave-aws'
gem 'carrierwave_backgrounder', '~> 0.4.1'
gem 'dalli', '~> 2.7.2'
gem 'devise', '~> 3.4.1'
gem 'foursquare2', '~> 2.0.1'
gem 'grocer', '~> 0.6.0'
gem 'hipchat', '~> 1.3.0'
gem 'hirefire-resource', '~> 0.3.4'
gem 'instagram', '~> 1.1.3'
# gem 'jbuilder', '~> 1.2'
gem 'jquery-rails'
gem 'kaminari', '~> 0.16.1'
gem 'koala', '~> 1.10.1'
gem 'mandrill_mailer', '~> 0.4.11'
gem 'mime-types'
gem 'mini_magick', github: 'minimagick/minimagick'
gem 'newrelic_rpm', '~> 3.9.6.257'
gem 'order_query', '~> 0.1.3'
gem 'paper_trail', '~> 3.0.6'
gem 'paranoia', '~> 2.0'
gem 'perforated', '~> 0.8.2'
gem 'piet-binary', '~> 0.2.0'
gem 'rack-cors', require: 'rack/cors'
gem 'rolify', '3.4'
gem 'rollbar', '~> 1.2.6'
gem 'sass-rails', '~> 4.0.0'
gem 'seedbank'
gem 'settingslogic'
gem 'sidekiq', '~> 3.2.6'
gem 'sidekiq-failures', '~> 0.4.3'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'slim-rails', '~> 2.1.5'
gem 'slugged', '~> 2.0'
gem 'turbolinks'
gem 'twitter', '~> 5.12.0'
gem 'twitter-text', '~> 1.10.0'
gem 'uglifier', '>= 1.3.0'
gem 'virtus', '~> 1.0.3'
gem 'zendesk_api', '~> 1.4.6'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'byebug'
  gem 'pry-byebug'
  gem 'rails_layout'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'rubocop', require: false
  gem 'terminal-notifier-guard'
end

group :development, :test do
  gem 'annotate', '~> 2.6.5'
  gem 'bullet', '~> 4.14.0'
  gem 'bundler-audit'
  gem 'childprocess', '0.3.6'
  gem 'did_you_mean', '~> 0.8.0'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'fuubar', '~> 1.3.2'
  gem 'guard-brakeman'
  gem 'guard-bundler'
  gem 'guard-sidekiq'
  gem 'guard-rails'
  gem 'guard-rails_best_practices'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-shell'
  gem 'rails_best_practices'
  gem 'rspec-instafail'
  gem 'rspec-rails'
  gem 'simplecov', '~> 0.9.1', require: false
end

group :test do
  gem 'codeclimate-test-reporter', group: :test, require: nil
  gem 'database_cleaner', '~> 1.3.0'
  gem 'email_spec'
  gem 'fakeredis', '~> 0.5.0', require: 'fakeredis/rspec'
  gem 'test_after_commit', '~> 0.3.0'
end

group :production, :staging do
  gem 'rails_12factor'
end
