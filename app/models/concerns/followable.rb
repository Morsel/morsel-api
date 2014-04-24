module Followable
  extend ActiveSupport::Concern

  included do
    has_many :followers, through: :follows, class_name: 'User'
    has_many :follows, as: :followable, dependent: :destroy
  end

  def follower_count
    followers.count
  end

  def follow_count
    follows.count
  end
end
