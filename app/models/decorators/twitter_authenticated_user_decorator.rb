class TwitterAuthenticatedUserDecorator < SimpleDelegator
  def post_twitter_message(twitter_message)
    twitter_client.update(twitter_message)
  end

  def post_twitter_photo_url(twitter_photo_url, twitter_message)
    if Rails.env.test?
      twitter_photo_file = open(twitter_photo_url)
    else
      twitter_photo_file = URI.parse(twitter_photo_url).open
    end

    return unless twitter_photo_file

    twitter_client.update_with_media(twitter_message, twitter_photo_file)
    twitter_photo_file.close
  end

  def twitter_username
    twitter_authentication.name if authenticated_with_twitter?
  end

  def build_twitter_authentication(authentication_params)
    authentication = authentications.build(authentication_params)

    twitter_client = twitter_client(authentication)
    twitter_current_user = twitter_client.current_user
    if twitter_current_user.present?
      authentication.uid = twitter_current_user.id
      authentication.name = twitter_current_user.screen_name
      authentication.link = twitter_current_user.url.to_s
    else
      authentication.errors.add(:token, 'is not valid') if authentication.uid?
    end

    authentication
  end

  def get_twitter_uid(authentication)
    twitter_client = twitter_client(authentication)
    if twitter_client.respond_to? :current_user
      twitter_client.current_user.id.to_s
    else
      nil
    end
  end

  def get_friends(authentication = twitter_authentication, cursor = -1)
    begin
      twitter_client(authentication).friend_ids(cursor: cursor)
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in + 1
      retry
    end
  end

  def get_followers(authentication = twitter_authentication, cursor = -1)
    begin
      twitter_client(authentication).follower_ids(cursor: cursor)
    rescue Twitter::Error::TooManyRequests => error
      sleep error.rate_limit.reset_in + 1
      retry
    end
  end

  private

  def twitter_authentication
    twitter_authentications.first
  end

  def authenticated_with_twitter?
    twitter_authentication && twitter_authentication.token.present? && twitter_authentication.secret.present?
  end

  def twitter_client(authentication = twitter_authentication)
    Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = authentication.token
      config.access_token_secret = authentication.secret
    end
  end
end
