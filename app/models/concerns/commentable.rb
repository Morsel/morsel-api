module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :commenters, through: :comments, class_name: 'User'
    has_many :comments, as: :commentable, dependent: :destroy
  end

  alias_attribute :comment_count, :comments_count
end
