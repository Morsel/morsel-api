class LikeAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    # Any User can CREATE a Like
    user.present?
  end
end
