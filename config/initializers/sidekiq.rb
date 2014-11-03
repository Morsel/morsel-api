require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { size: 2 }
end

Sidekiq.configure_server do |config|
  config = Rails.application.config.database_configuration[Rails.env]
  config['pool']              = ENV['SIDEKIQ_DB_POOL'] || 10
  config['reaping_frequency'] = ENV['SIDEKIQ_DB_REAP_FREQ'] || 10
  ActiveRecord::Base.establish_connection(config)
end
