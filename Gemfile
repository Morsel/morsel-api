source 'https://rubygems.org'

ruby '2.0.0'
#ruby-gemset=morsel

gem 'rails', '4.0.2'
gem 'pg'

gem 'activeadmin', github: 'gregbell/active_admin'
gem 'bootstrap-sass', '>= 3.0.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'cancan'
gem "carrierwave", "~> 0.9.0"
gem 'carrierwave-aws'
gem 'devise', "~> 3.2.2"
# gem 'doorkeeper', '~> 0.7.0'
# gem 'formtastic'
gem 'jbuilder', '~> 1.2'
gem 'jquery-rails'
gem "koala", "~> 1.8.0rc1"
gem 'mime-types'
gem 'newrelic_rpm'
gem 'paranoia', '~> 2.0'
gem 'rack-cors', require: 'rack/cors'
gem 'rolify'
gem 'rollbar'
gem 'sass-rails', '~> 4.0.0'
gem 'settingslogic'
gem 'slim-rails'
gem 'slugged', '~> 2.0'
gem 'turbolinks'
gem "twitter", "~> 5.5.1"
gem 'uglifier', '>= 1.3.0'
gem 'unicorn'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'quiet_assets'
  gem 'pry'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
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
  gem 'guard-rails'
  gem 'guard-rails_best_practices'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-spork', '1.5.0'
  gem 'guard-shell'
  gem 'rails_best_practices'
  gem 'rspec-instafail'
  gem 'rspec-rails'
  gem 'spork-rails', '4.0.0'
end

group :test do
  gem "codeclimate-test-reporter", group: :test, require: nil
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
end

group :production do
  gem 'rails_12factor'
end
