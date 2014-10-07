class SocialWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])
    if options['post_to_facebook'] && morsel.photo_url
      FacebookAuthenticatedUserDecorator.new(User.includes(:facebook_authentications).find(options['user_id'])).post_facebook_photo_url(morsel.photo_url, SocialMorselDecorator.new(morsel).facebook_message)
    elsif options['post_to_twitter'] && morsel.photo_url
      TwitterAuthenticatedUserDecorator.new(User.includes(:twitter_authentications).find(options['user_id'])).post_twitter_photo_url(morsel.photo_url, SocialMorselDecorator.new(morsel).twitter_message)
    end
  end
end
