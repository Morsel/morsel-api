class FetchSocialConnectionUids
  include Service

  attribute :authentication, Authentication
  attribute :user, User

  validates :authentication, presence: true
  validates :user, presence: true

  def call
    if authentication.provider == 'facebook'
      facebook_uids
    end
  end

  private

  def facebook_uids
    FacebookAuthenticatedUserDecorator.new(user).get_connections(authentication).map { |connection| connection['id'] }
  end
end
