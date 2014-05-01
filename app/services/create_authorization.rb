class CreateAuthorization
  include Service
  include Virtus.model

  attribute :user, User
  attribute :provider, String
  attribute :token, String
  attribute :secret, String

  def call
    if provider == 'facebook'
      build_facebook_authorization
    elsif provider == 'twitter'
      build_twitter_authorization
    else
      user.authorizations.build(authorization_attributes)
    end
  end

  private

  def authorization_attributes
    attributes.except :user
  end

  def build_facebook_authorization
    FacebookUserDecorator.new(user).build_facebook_authorization(authorization_attributes)
  end

  def build_twitter_authorization
    TwitterUserDecorator.new(user).build_twitter_authorization(authorization_attributes)
  end
end
