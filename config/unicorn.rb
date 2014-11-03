# config/unicorn.rb
# based off of: https://gist.github.com/leshill/1401792

worker_processes ENV['UNICORN_WORKER_PROCESS_COUNT'].to_i || 2 # Settingslogic craps out so inline ENV
timeout 30
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  if defined?(ActiveRecord::Base)
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = Settings.database.reaping_frequency
    config['pool']            =   Settings.database.pool
    ActiveRecord::Base.establish_connection(config)
    Rails.logger.info('Connected to ActiveRecord')
  end
end
