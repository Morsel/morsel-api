class NewsletterWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?    
    NewsletterService.call(options)
  end
end