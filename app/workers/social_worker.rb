class SocialWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])
    if options['post_to_facebook']
      SendMorselToSocial.call(morsel: morsel, provider: 'facebook', user_id: options['user_id'])
    elsif options['post_to_twitter']
      SendMorselToSocial.call(morsel: morsel, provider: 'twitter', user_id: options['user_id'])
    end
  end
end
