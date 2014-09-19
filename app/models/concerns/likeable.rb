module Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likers, through: :likes, class_name: 'User'
    has_many :likes, as: :likeable, dependent: :destroy

    scope :liked_by, -> (liker_id) do
      joins("LEFT OUTER JOIN likes ON likes.likeable_type = '#{base_class}' AND likes.likeable_id = #{table_name}.id AND likes.deleted_at IS NULL AND #{table_name}.deleted_at IS NULL")
      .includes(:creator, :morsel)
      .where(likes: { liker_id: liker_id })
    end
  end

  def like_count
    likes.count
  end
end
