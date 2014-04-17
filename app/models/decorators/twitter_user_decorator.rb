class TwitterUserDecorator < SimpleDelegator
  def post_twitter_message(twitter_message)
    user_twitter_client.update(twitter_message)
  end

  def post_twitter_photo_url(twitter_photo_url, twitter_message)
    twitter_photo_file = URI.parse(twitter_photo_url).open
    if twitter_photo_file
      user_twitter_client.update_with_media(twitter_message, twitter_photo_file)
      twitter_photo_file.close
    end
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
