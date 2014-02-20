class CreateAuthorization < ActiveInteraction::Base
  model  :user

  string :provider, :token
  string :secret, default: nil

  def execute
    authorization = user.authorizations.build(provider: provider,
                                              token: token,
                                              secret: secret)

    case provider
    when 'facebook'
      build_facebook_attributes(authorization)
    when 'twitter'
      build_twitter_attributes(authorization)
    end

    authorization
  end

  private

  def build_facebook_attributes(authorization)
    facebook_user = Koala::Facebook::API.new(token).get_object('me')

    if facebook_user.present?
      authorization.uid = facebook_user['id'] if facebook_user['id'].present?
      authorization.name = facebook_user['name'] if facebook_user['name'].present?
      authorization.link = facebook_user['link'] if facebook_user['link'].present?
      user.save
    else
      authorization.errors.add(:token, 'is not valid') if authorization.uid?
    end
  end

  def build_twitter_attributes(authorization)
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = authorization.token
      config.access_token_secret = authorization.secret
    end

    if twitter_client.current_user.present?
      authorization.uid = twitter_client.current_user.id
      authorization.name = twitter_client.current_user.screen_name
      authorization.link = twitter_client.current_user.url.to_s
      user.save
    else
      authorization.errors.add(:token, 'is not valid') if authorization.uid?
    end
  end
end
