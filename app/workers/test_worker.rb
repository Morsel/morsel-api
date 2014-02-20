class TestWorker
  include Sidekiq::Worker

  def perform(message)
    Rails.logger.info "#{message}"
    if message.start_with? 'error'
      begin
        raise message
      rescue StandardError => e
        raise e
      end
    end
  end
end
