class SocialWorker
  include Sidekiq::Worker

  def perform(network, user_id, morsel_id)
    user = User.includes(:authorizations).find(user_id)
    morsel = Morsel.find morsel_id

    if morsel.photo.nil?
      collage_generator_decorated_morsel = MorselCollageGeneratorDecorator.new(morsel)
      collage_generator_decorated_morsel.generate
    end

    case network
    when 'facebook'
      FacebookUserDecorator.new(user).morsel_facebook_message(morsel.facebook_message)
    when 'twitter'
      TwitterUserDecorator.new(user).morsel_twitter_message(morsel.twitter_message)
    else
      raise "Invalid Network: #{network}"
    end
  end
end
