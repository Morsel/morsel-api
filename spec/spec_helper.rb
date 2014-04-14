ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec'
require 'email_spec'
require 'factory_girl'
require 'sidekiq/testing'
require 'mandrill_mailer/offline'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include Requests::JsonHelpers, type: :request
  config.include Requests::ServiceStubs, type: :request

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
  end

  config.after(:each) do
    DatabaseCleaner.clean
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
  end
end
