class MrslWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])

    # generate facebook mrsl link if it doesn't already exist
    morsel.facebook_mrsl = Mrsl.shorten(morsel.url, 'facebook', 'share', "morsel-#{morsel.id}") if morsel.facebook_mrsl.nil?

    # generate twitter mrsl link if it doesn't already exist
    morsel.twitter_mrsl = Mrsl.shorten(morsel.url, 'twitter', 'share', "morsel-#{morsel.id}") if morsel.twitter_mrsl.nil?

    # save morsel if either mrsl was created
    morsel.save if morsel.changed?

    if morsel.feed_item.nil?
      FeedWorker.perform_async(options)
    else
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
