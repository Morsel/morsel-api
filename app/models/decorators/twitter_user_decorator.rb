class TwitterUserDecorator < SimpleDelegator
  def queue_twitter_message(morsel_id)
    SocialWorker.perform_async(:twitter, id, morsel_id) if authorized_with_twitter?
  end

  def post_twitter_message(message)
    user_twitter_client.update(message)
  end

  def twitter_username
    twitter_authorization.name if authorized_with_twitter?
  end

  def build_twitter_authorization(authorization_params)
    authorization = self.authorizations.build(authorization_params)

    twitter_client = twitter_client(authorization)

    if twitter_client.current_user.present?
      authorization.uid = twitter_client.current_user.id
      authorization.name = twitter_client.current_user.screen_name
      authorization.link = twitter_client.current_user.url.to_s
    else
      authorization.errors.add(:token, 'is not valid') if authorization.uid?
    end

    authorization
  end

  private

  def twitter_authorization
    twitter_authorizations.first
  end

  def authorized_with_twitter?
    twitter_authorization && twitter_authorization.token.present? && twitter_authorization.secret.present?
  end

  def user_twitter_client
    twitter_client(twitter_authorization) if authorized_with_twitter?
  end

  def twitter_client(authorization)
    Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = authorization.token
      config.access_token_secret = authorization.secret
    end
  end
end
