ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec'
require 'database_cleaner'
require 'email_spec'
require 'factory_girl'
require 'sidekiq/testing'
require 'mandrill_mailer/offline'
require 'fakeredis/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'

  config.include SpecHelpers
  config.include ServiceStubs

  config.before(:suite) do
    ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

    FactoryGirl.sequences.clear
    FactoryGirl.factories.clear
    Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| load f }
    ENV.update Dotenv::Environment.new('.env.test')
    Settings.reload!

    DatabaseCleaner.clean_with(:truncation)

    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do |example_method|
    DatabaseCleaner.start
    MandrillMailer.deliveries.clear

    # Clears out the jobs for tests using the fake testing
    Sidekiq::Worker.clear_all
    # Get the current example from the example_method object
    example = example_method.example

    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!
    elsif example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end

    Bullet.start_request if Bullet.enable?
  end

  config.after(:each) do
    DatabaseCleaner.clean
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])

    if Bullet.enable?
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
