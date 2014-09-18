class FetchSocialFollowerUids
  include Service

  attribute :authentication, Authentication

  validates :authentication, presence: true

  def call
    if authentication.instagram?
      instagram_uids
    elsif authentication.twitter?
      twitter_uids
    end
  end

  private

  def instagram_uids
    InstagramAuthenticatedUserDecorator.new(authentication.user).get_followers(authentication).map { |connection| connection['id'] }
  end

  def twitter_uids
    TwitterAuthenticatedUserDecorator.new(authentication.user).get_followers(authentication).map(&:to_s)
  end
end
