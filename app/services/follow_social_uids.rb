class FollowSocialUids
  include Service

  attribute :authentication, Authentication
  attribute :uids, Array

  validates :authentication, presence: true

  def call
    followed_users = []
    connected_users.find_each do |connected_user|
      followed_users << connected_user if authentication.user.auto_follow? && Follow.create(followable: connected_user, follower_id: authentication.user_id, silent: true)
    end
    followed_users
  end

  private

  def connected_users
    User.joins(:authentications).where(authentications: { provider: authentication.provider, uid: uids })
  end
end
