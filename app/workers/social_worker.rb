class SocialWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    user = User.find(options['user_id'])
    morsel = Morsel.find(options['morsel_id'])
    if options['post_to_facebook'] && morsel.photo_url
      FacebookUserDecorator.new(user).post_facebook_photo_url(morsel.photo_url, morsel.facebook_message)
    elsif options['post_to_twitter'] && morsel.photo_url
      TwitterUserDecorator.new(user).post_twitter_photo_url(morsel.photo_url, morsel.twitter_message)
    end
  end
end
