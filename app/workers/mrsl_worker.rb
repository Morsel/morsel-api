class MrslWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])
    morsel.published_at = nil
    morsel.update! draft: false, publishing: false

    MorselMrslDecorator.new(morsel).generate_mrsl_links!

    if morsel.feed_item.nil?
      FeedWorker.perform_async(options)
    else
      SocialWorker.perform_async(options.except('post_to_twitter')) if options['post_to_facebook']
      SocialWorker.perform_async(options.except('post_to_facebook')) if options['post_to_twitter']
    end
  end
end
