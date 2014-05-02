class FacebookAuthenticatedUserDecorator < SimpleDelegator
  def post_facebook_message(facebook_message)
    facebook_client.put_connections('me', 'feed', message: facebook_message)
  end

  def post_facebook_photo_url(facebook_photo_url, facebook_message)
    facebook_client.put_picture(facebook_photo_url, {message: facebook_message})
  end

  def facebook_uid
    facebook_authentication.uid if authenticated_with_facebook?
  end

  def build_facebook_authentication(authentication_params)
    authentication = self.authentications.build(authentication_params)

    facebook_user_object = Koala::Facebook::API.new(authentication.token).get_object('me')

    if facebook_user_object.present?
      authentication.uid = facebook_user_object['id'].presence
      authentication.name = facebook_user_object['name'].presence
      authentication.link = facebook_user_object['link'].presence
    else
      authentication.errors.add(:token, 'is not valid')
    end

    authentication
  end

  def facebook_valid?
    begin
      if facebook_client.get_object("me")
        true
      else
        false
      end
    rescue Koala::Facebook::APIError
      false
    end
  end

  private

  def facebook_authentication
    facebook_authentications.first
  end

  def authenticated_with_facebook?
    facebook_authentication && facebook_authentication.token.present?
  end

  def facebook_client
    Koala::Facebook::API.new(facebook_authentication.token) if authenticated_with_facebook?
  end
end
