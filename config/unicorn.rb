# config/unicorn.rb
# based off of: https://gist.github.com/leshill/1401792

worker_processes ENV['UNICORN_WORKER_PROCESS_COUNT'] || 2
timeout 30
preload_app true

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end
end
