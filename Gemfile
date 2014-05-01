source 'https://rubygems.org'

ruby '2.0.0'
#ruby-gemset=morsel

gem 'puma'
gem 'rails', '4.0.3'
gem 'pg'

gem 'active_model_serializers'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'addressable', '~> 2.3.6'
gem "authority", "~> 2.9.0"
gem 'bitly', '~> 0.10.1'
gem 'bootstrap-sass', '>= 3.0.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem "carrierwave", "~> 0.9.0"
gem 'carrierwave-aws'
gem 'carrierwave_backgrounder'
gem 'devise', "~> 3.2.2"
# gem 'doorkeeper', '~> 0.7.0'
# gem 'formtastic'
gem 'hirefire-resource', '~> 0.3.2'
gem 'jbuilder', '~> 1.2'
gem 'jquery-rails'
gem "koala", "~> 1.8.0rc1"
gem "mandrill_mailer", "~> 0.4.3"
gem 'mime-types'
gem 'mini_magick', github: 'minimagick/minimagick'
gem 'newrelic_rpm'
gem 'paranoia', '~> 2.0'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-perftools_profiler', require: 'rack/perftools_profiler'
gem 'rolify'
gem 'rollbar'
gem 'sass-rails', '~> 4.0.0'
gem 'seedbank'
gem 'settingslogic'
gem 'sidekiq', '~> 3.0.0'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'slim-rails'
gem 'slugged', '~> 2.0'
gem 'turbolinks'
gem "twitter", "~> 5.5.1"
gem 'uglifier', '>= 1.3.0'
gem 'virtus'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:mri_20]
  gem 'quiet_assets'
  gem 'pry'
  gem 'pry-debugger'
  gem 'rails_layout'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'rubocop', require: false
  gem 'terminal-notifier-guard'
end

group :development, :test do
  gem 'annotate', '>= 2.6.0'
  gem 'bundler-audit'
  gem 'childprocess', '0.3.6'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem "fuubar", "~> 1.3.2"
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
end

group :test do
  gem "codeclimate-test-reporter", group: :test, require: nil
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
end

group :production, :staging do
  gem 'rails_12factor'
end
