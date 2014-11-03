require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { size: 2 }
end

Sidekiq.configure_server do |config|
  config = Rails.application.config.database_configuration[Rails.env]
  config['reaping_frequency'] = Settings.sidekiq.reaping_frequency
  config['pool']            =   Settings.sidekiq.pool
  ActiveRecord::Base.establish_connection(config)
end
