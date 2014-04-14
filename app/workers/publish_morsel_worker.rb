class PublishMorselWorker
  include Sidekiq::Worker

  # :morsel_id, :user_id, :post_to_facebook, :post_to_twitter
  def perform(options = nil)
    return if options.nil?
    CollageWorker.perform_async(options)
  end
end
