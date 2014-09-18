class ReverseFollowSocialUids
  include Service

  attribute :authentication, Authentication
  attribute :uids, Array

  validates :authentication, presence: true

  def call
    followers = []
    connected_users.find_each do |connected_user|
      followers << connected_user if connected_user.auto_follow? && Follow.create(followable_id: authentication.user_id, followable_type: 'User', follower: connected_user)
    end
    followers
  end

  private

  def connected_users
    User.joins(:authentications).where(authentications: { provider: authentication.provider, uid: uids })
  end
end
