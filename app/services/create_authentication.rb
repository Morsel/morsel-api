class CreateAuthentication
  include Service
  include Virtus.model

  attribute :user, User
  attribute :provider, String
  attribute :token, String
  attribute :secret, String

  def call
    if provider == 'facebook'
      build_facebook_authentication
    elsif provider == 'twitter'
      build_twitter_authentication
    else
      user.authentications.build(authentication_attributes)
    end
  end

  private

  def authentication_attributes
    attributes.except :user
  end

  def build_facebook_authentication
    FacebookAuthenticatedUserDecorator.new(user).build_facebook_authentication(authentication_attributes)
  end

  def build_twitter_authentication
    TwitterAuthenticatedUserDecorator.new(user).build_twitter_authentication(authentication_attributes)
  end
end
