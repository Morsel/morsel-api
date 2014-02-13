class SocialWorker
  include Sidekiq::Worker

  def perform(network, user_id, message)
    user = User.includes(:authorizations).find(user_id)
    case network
    when 'facebook'
      user.facebook_client.put_connections('me', 'feed', message: message)
    when 'twitter'
      user.twitter_client.update(message)
    else
      raise "Invalid Network: #{network}"
    end
  end
end
