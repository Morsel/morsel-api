class MrslWorker
  include Sidekiq::Worker

  def perform(morsel_id)
    morsel = Morsel.find(morsel_id)

    # generate facebook mrsl link if it doesn't already exist
    morsel.facebook_mrsl = Mrsl.shorten(morsel.url, 'facebook', 'share', "morsel-#{morsel.id}") if morsel.facebook_mrsl.nil?

    # generate twitter mrsl link if it doesn't already exist
    morsel.twitter_mrsl = Mrsl.shorten(morsel.url, 'twitter', 'share', "morsel-#{morsel.id}") if morsel.twitter_mrsl.nil?

    # save morsel if either mrsl was created
    morsel.save if morsel.changed?
  end
end
