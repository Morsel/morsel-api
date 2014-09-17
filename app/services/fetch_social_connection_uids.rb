class FetchSocialConnectionUids
  include Service

  attribute :authentication, Authentication

  validates :authentication, presence: true

  def call
    if authentication.facebook?
      facebook_uids
    elsif authentication.instagram?
      instagram_uids
    elsif authentication.twitter?
      twitter_uids
    end
  end

  private

  def facebook_uids
    FacebookAuthenticatedUserDecorator.new(authentication.user).get_connections(authentication).map { |connection| connection['id'] }
  end

  def instagram_uids
    InstagramAuthenticatedUserDecorator.new(authentication.user).get_connections(authentication).map { |connection| connection['id'] }
  end

  def twitter_uids
    TwitterAuthenticatedUserDecorator.new(authentication.user).get_connections(authentication).map(&:to_s)
  end
end
