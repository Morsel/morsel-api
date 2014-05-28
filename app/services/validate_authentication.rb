class ValidateAuthentication
  include Service

  attribute :authentication, Authentication

  validate :uid_match

  def call
    true
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
    # Need to make sure that the token passed belong to the uid passed
    errors.add(:authentication, 'is invalid') if fetched_uid != authentication.uid
  end
end
