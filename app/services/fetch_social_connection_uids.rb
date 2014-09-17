class FetchSocialConnectionUids
  include Service

  attribute :authentication, Authentication
  attribute :user, User

  validates :authentication, presence: true
  validates :user, presence: true

  def call
    if authentication.facebook?
      facebook_uids
    elsif authentication.twitter?
      twitter_uids
    end
  end

  private

  def facebook_uids
    FacebookAuthenticatedUserDecorator.new(user).get_connections(authentication).map { |connection| connection['id'] }
  end

  def twitter_uids
    TwitterAuthenticatedUserDecorator.new(user).get_connections(authentication).map(&:to_s)
  end
end
