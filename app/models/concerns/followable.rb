module Followable
  extend ActiveSupport::Concern

  included do
    has_many :follower_follows, as: :followable, class_name: 'Follow', dependent: :destroy
    has_many :followers, through: :follower_follows, class_name: 'User'

    scope :followed_by, -> (follower_id) do
      joins("LEFT OUTER JOIN follows ON follows.followable_type = '#{base_class}' AND follows.followable_id = #{table_name}.id AND follows.deleted_at IS NULL AND #{table_name}.deleted_at IS NULL")
      .where(follows: { follower_id: follower_id })
    end
  end

  def follower_count
    followers.count
  end

  def follow_count
    follower_follows.count
  end
end
