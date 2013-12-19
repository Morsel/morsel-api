source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '4.0.2'
gem 'pg'

gem 'bootstrap-sass', '>= 3.0.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jbuilder', '~> 1.2'
gem 'jquery-rails'
# gem 'paperclip'
gem 'sass-rails', '~> 4.0.0'
gem 'slim-rails'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'
gem 'unicorn'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'quiet_assets'
  gem 'pry'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'terminal-notifier-guard'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-instafail'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem "codeclimate-test-reporter", group: :test, require: nil
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
end
