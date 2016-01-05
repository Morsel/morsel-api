class CreateAuthentication
  include Service

  attribute :user, User
  attribute :provider, String
  attribute :uid, String
  attribute :token, String
  attribute :secret, String
  attribute :short_lived, String
  attribute :email, String
  validates :provider, presence: true
  validates :token, presence: true
  validates :uid, presence: true
  validates :user, presence: true

  validate :secret_required?

  def call
    if provider == 'facebook'
      authentication = FacebookAuthenticatedUserDecorator.new(user).build_facebook_authentication(authentication_attributes)
    elsif provider == 'instagram'
      authentication = InstagramAuthenticatedUserDecorator.new(user).build_instagram_authentication(authentication_attributes)
    elsif provider == 'twitter'
      authentication = TwitterAuthenticatedUserDecorator.new(user).build_twitter_authentication(authentication_attributes)
    else
      authentication = user.authentications.build(authentication_attributes)
    end

    authentication.auto_follow = user.auto_follow?
    authentication.save
    authentication
  end

  private

  def authentication_attributes
    attributes.except :user
  end

  def secret_required?
    errors.add(:secret, 'is required') if secret.nil? && provider == 'twitter'
  end
end
