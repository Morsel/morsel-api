class SocialWorker
  include Sidekiq::Worker

  def perform(network, user_id, message)
    user = User.includes(:authorizations).find(user_id)
    if user
      case network
      when :facebook
        facebook_client = user.facebook_client
        facebook_client.put_connections('me', 'feed', message: message) if facebook_client
      when :twitter
        twitter_client = user.twitter_client
        twitter_client.update(message) if twitter_client
      end
    end
  end
end
