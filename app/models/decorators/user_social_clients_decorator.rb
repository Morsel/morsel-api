class UserSocialClientsDecorator < SimpleDelegator
  def facebook_client
    Koala::Facebook::API.new(facebook_authorization.token) if authorized_with_facebook?
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
