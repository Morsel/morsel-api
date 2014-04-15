class FeedWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    feed_item = FeedItem.new(
      subject_id: options['morsel_id'],
      subject_type: 'Morsel'
    )

    if feed_item.save
      if options['post_to_facebook']
        options['post_to_twitter'] = nil
        SocialWorker.perform_async(options)
      end
      if options['post_to_twitter']
        options['post_to_facebook'] = nil
        SocialWorker.perform_async(options)
      end
    end
  end
end
