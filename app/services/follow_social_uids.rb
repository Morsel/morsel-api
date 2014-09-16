class FollowSocialUids
  include Service

  attribute :authentication, Authentication
  attribute :uids, Array
  attribute :user, User

  validates :authentication, presence: true
  validates :user, presence: true

  def call
    followed_users = []
    connected_users.find_each do |connected_user|
      follow = Follow.create(followable: connected_user, follower_id: user.id)
      followed_users << follow if follow.id
    end
    followed_users
  end

  private

  def connected_users
    User.joins(:authentications).where(authentications: { provider: authentication.provider, uid: uids })
  end
end
