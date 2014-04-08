class FacebookUserDecorator < SimpleDelegator
  def queue_facebook_message(post_id)
    SocialWorker.perform_async(:facebook, id, post_id) if authorized_with_facebook?
  end

  def post_message(message)
    facebook_client.put_connections('me', 'feed', message: message)
  end

  def facebook_uid
    facebook_authorization.uid if authorized_with_facebook?
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
