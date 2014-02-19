class SocialWorker
  include Sidekiq::Worker

  def perform(network, user_id, message)
    user = User.includes(:authorizations).find(user_id)
    social_clients_decorated_user = UserSocialClientsDecorator.new(user)
    case network
    when 'facebook'
      social_clients_decorated_user.facebook_client.put_connections('me', 'feed', message: message)
    when 'twitter'
      social_clients_decorated_user.twitter_client.update(message)
    else
      raise "Invalid Network: #{network}"
    end
  end
end
