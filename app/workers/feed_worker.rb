class FeedWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    feed_item = FeedItem.new(
      subject_id: options['morsel_id'],
      subject_type: 'Morsel',
      visible: true
    )

    if feed_item.save
      SocialWorker.perform_async(options.except('post_to_twitter')) if options['post_to_facebook']
      SocialWorker.perform_async(options.except('post_to_facebook')) if options['post_to_twitter']
    end
  end
end
