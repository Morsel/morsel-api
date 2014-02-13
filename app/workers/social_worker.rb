class SocialWorker
  include Sidekiq::Worker

  def perform(network, user_id, message)
    begin
      user = User.includes(:authorizations).find(user_id)
      case network
      when :facebook
        user.facebook_client.put_connections('me', 'feed', message: message)
      when :twitter
        user.twitter_client.update(message)
      end
    rescue StandardError => e
      raise e
    end
  end
end
