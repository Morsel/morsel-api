class BuildAuthentication
  include Service

  attribute :user, User
  attribute :provider, String
  attribute :uid, String
  attribute :token, String
  attribute :secret, String
  attribute :short_lived, String

  validates :provider, presence: true
  validates :secret, presence: true
  validates :user, presence: true

  def call
    if provider == 'facebook'
      FacebookAuthenticatedUserDecorator.new(user).build_facebook_authentication(authentication_attributes)
    elsif provider == 'instagram'
      InstagramAuthenticatedUserDecorator.new(user).build_instagram_authentication(authentication_attributes)
    elsif provider == 'twitter'
      TwitterAuthenticatedUserDecorator.new(user).build_twitter_authentication(authentication_attributes)
    else
      user.authentications.build(authentication_attributes)
    end
  end

  private

  def authentication_attributes
    attributes.except :user
  end
end
