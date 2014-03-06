class LikeAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    # Anyone can CREATE a Like
    true
  end
end
