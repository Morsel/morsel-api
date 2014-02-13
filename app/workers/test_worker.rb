class TestWorker
  include Sidekiq::Worker

  def perform(message)
    puts "#{message}"
    if message.start_with? 'error'
      begin
        raise message
      rescue StandardError => e
        raise e
      end
    end
  end
end
