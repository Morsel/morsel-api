class FeedWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    feed_item = FeedItem.new(
      subject_id: options['morsel_id'],
      subject_type: 'Morsel',
      place_id: options['place_id'],
      user_id: options['user_id'],
      visible: true
    )

    if feed_item.save
      SocialWorker.perform_async(options.except('post_to_twitter')) if options['post_to_facebook']
      SocialWorker.perform_async(options.except('post_to_facebook')) if options['post_to_twitter']
      PublishedMorselHipChatNotificationWorker.perform_async(options) if Rails.env.production?
      ActivitySubscription.where(subject_id: feed_item.subject_id, subject_type: 'Morsel').update_all active: true
      ActivitySubscription.where(subject_id: feed_item.subject.item_ids, subject_type: 'Item').update_all active: true
      NotifyTaggedMorselUsersWorker.perform_async(options)
    end
  end
end
