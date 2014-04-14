class SocialWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    user = User.find(options['user_id'])
    morsel = Morsel.find(options['morsel_id'])

    if options['post_to_facebook']
      FacebookUserDecorator.new(user).post_facebook_message(morsel.facebook_message)
    elsif options['post_to_twitter']
      TwitterUserDecorator.new(user).post_twitter_message(morsel.twitter_message)
    end
  end
end
