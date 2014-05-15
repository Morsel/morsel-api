module Followable
  extend ActiveSupport::Concern

  included do
    has_many :follower_follows, as: :followable, class_name: 'Follow', dependent: :destroy
    has_many :followers, through: :follower_follows, class_name: 'User'
  end

  def follower_count
    followers.count
  end

  def follow_count
    follows.count
  end
end
