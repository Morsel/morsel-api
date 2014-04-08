class TwitterUserDecorator < SimpleDelegator
  def queue_twitter_message(post_id)
    SocialWorker.perform_async(:twitter, id, post_id) if authorized_with_twitter?
  end

  def post_twitter_message(message)
    twitter_client.update(message)
  end

  def twitter_username
    twitter_authorization.name if authorized_with_twitter?
  end

  private

  def twitter_authorization
    twitter_authorizations.first
  end

  def authorized_with_twitter?
    twitter_authorization && twitter_authorization.token.present? && twitter_authorization.secret.present?
  end

  def twitter_client
    if authorized_with_twitter?
      Twitter::REST::Client.new do |config|
        config.consumer_key = Settings.twitter.consumer_key
        config.consumer_secret = Settings.twitter.consumer_secret
        config.access_token = twitter_authorization.token
        config.access_token_secret = twitter_authorization.secret
      end
    end
  end
end
