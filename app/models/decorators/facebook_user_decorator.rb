class FacebookUserDecorator < SimpleDelegator
  def post_facebook_message(message)
    facebook_client.put_connections('me', 'feed', message: message)
  end

  def facebook_uid
    facebook_authorization.uid if authorized_with_facebook?
  end

  def build_facebook_authorization(authorization_params)
    authorization = self.authorizations.build(authorization_params)

    facebook_user_object = Koala::Facebook::API.new(authorization.token).get_object('me')

    if facebook_user_object.present?
      authorization.uid = facebook_user_object['id'].presence
      authorization.name = facebook_user_object['name'].presence
      authorization.link = facebook_user_object['link'].presence
    else
      authorization.errors.add(:token, 'is not valid')
    end

    authorization
  end

  private

  def facebook_authorization
    facebook_authorizations.first
  end

  def authorized_with_facebook?
    facebook_authorization && facebook_authorization.token.present?
  end

  def facebook_client
    Koala::Facebook::API.new(facebook_authorization.token) if authorized_with_facebook?
  end
end
