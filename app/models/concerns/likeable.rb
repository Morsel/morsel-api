module Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likers, through: :likes, class_name: 'User'
    has_many :likes, as: :likeable, dependent: :destroy
  end

  def like_count
    likes.count
  end
end
