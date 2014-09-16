class FacebookAuthenticatedUserDecorator < SimpleDelegator
  def post_facebook_message(facebook_message)
    facebook_client.put_connections('me', 'feed', message: facebook_message)
  end

  def post_facebook_photo_url(facebook_photo_url, facebook_message)
    facebook_client.put_picture(facebook_photo_url, message: facebook_message)
  end

  def facebook_uid
    facebook_authentication.uid if authenticated_with_facebook?
  end

  def build_facebook_authentication(authentication_params)
    authentication = authentications.build(authentication_params)

    facebook_user_object = facebook_client(authentication).get_object('me')

    if facebook_user_object.present?
      authentication.uid = facebook_user_object['id'].presence
      authentication.name = facebook_user_object['name'].presence
      authentication.link = facebook_user_object['link'].presence
      authentication.exchange_access_token
    else
      authentication.errors.add(:token, 'is not valid')
    end

    authentication
  end

  def get_facebook_uid(authentication)
    facebook_client(authentication).get_object('me')['id']
  rescue Koala::Facebook::APIError
    nil
  end

  def get_connections(authentication = facebook_authentication)
    facebook_client(authentication).get_connections('me', 'friends')
  end

  private

  def facebook_authentication
    facebook_authentications.first
  end

  def authenticated_with_facebook?(authentication = facebook_authentication)
    authentication && authentication.token.present?
  end

  def facebook_client(authentication = facebook_authentication)
    @facebook_client ||= Koala::Facebook::API.new(authentication.token) if authenticated_with_facebook?(authentication)
  end
end
