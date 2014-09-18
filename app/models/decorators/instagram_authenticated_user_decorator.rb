class InstagramAuthenticatedUserDecorator < SimpleDelegator
  def instagram_username
    instagram_authentication.name if authenticated_with_instagram?
  end

  def build_instagram_authentication(authentication_params)
    authentication = authentications.build(authentication_params)

    instagram_client = instagram_client(authentication)
    instagram_user = instagram_client.user

    if instagram_user.present?
      authentication.uid = instagram_user.id
      authentication.name = instagram_user.username
      authentication.link = "http://instagram.com/#{instagram_user.username}" if instagram_user.username.present?
    else
      authentication.errors.add(:token, 'is not valid') if authentication.uid?
    end

    authentication
  end

  def get_friends(authentication = instagram_authentication)
    instagram_client(authentication).user_follows
  end

  private

  def instagram_authentication
    instagram_authentications.first
  end

  def authenticated_with_instagram?
    instagram_authentication && instagram_authentication.token.present?
  end

  def instagram_client(authentication = instagram_authentication)
    Instagram::Client.new(access_token: authentication.token)
  end
end
