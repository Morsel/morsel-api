class ValidateAuthentication
  include Service
  include Virtus.model

  attribute :authentication, Authentication

  def call
    # Need to make sure that the token passed belong to the uid passed
    uid_match
  end

  private

  def fetched_uid
    if authentication.facebook?
      FacebookAuthenticatedUserDecorator.new(authentication.user).get_facebook_uid(authentication)
    elsif authentication.instagram?
      InstagramAuthenticatedUserDecorator.new(authentication.user).get_instagram_uid(authentication)
    elsif authentication.twitter?
      TwitterAuthenticatedUserDecorator.new(authentication.user).get_twitter_uid(authentication)
    end
  end

  def uid_match
    fetched_uid == authentication.uid
  end
end
