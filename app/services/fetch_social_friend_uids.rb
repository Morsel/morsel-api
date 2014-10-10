class FetchSocialFriendUids
  include Service

  attribute :authentication, Authentication
  attribute :cursor, Number

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
    FacebookAuthenticatedUserDecorator.new(authentication.user).get_friends(authentication).map { |connection| connection['id'] }
  end

  def instagram_uids
    InstagramAuthenticatedUserDecorator.new(authentication.user).get_friends(authentication).map { |connection| connection['id'] }
  end

  def twitter_uids
    TwitterAuthenticatedUserDecorator.new(authentication.user).get_friends(authentication, cursor)
  end
end
