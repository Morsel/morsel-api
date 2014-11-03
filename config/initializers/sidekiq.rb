require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { size: 2 }

  Rails.application.config.after_initialize do
    ActiveRecord::Base.connection_pool.disconnect!

    ActiveSupport.on_load(:active_record) do
      config = Rails.application.config.database_configuration[Rails.env]
      config['reaping_frequency'] = ENV['DB_POOL'] || 10
      config['pool'] = ENV['DB_REAP_FREQ'] || 10
      ActiveRecord::Base.establish_connection(config)

      # DB connection not available during slug compliation on Heroku
      Rails.logger.info("Connection Pool size for web server is now: #{config['pool']}")
    end
  end
end

Sidekiq.configure_server do |config|
  Rails.application.config.after_initialize do
    ActiveRecord::Base.connection_pool.disconnect!

    ActiveSupport.on_load(:active_record) do
      config = Rails.application.config.database_configuration[Rails.env]
      config['reaping_frequency'] = ENV['SIDEKIQ_DB_REAP_FREQ'] || 10
      config['pool'] = ENV['SIDEKIQ_DB_POOL'] || 10
      ActiveRecord::Base.establish_connection(config)

      Rails.logger.info("Connection Pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
    end
  end
end
