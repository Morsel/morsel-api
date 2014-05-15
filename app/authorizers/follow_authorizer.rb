class FollowAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    # Any User can CREATE a Follow
    user.present?
  end
end
