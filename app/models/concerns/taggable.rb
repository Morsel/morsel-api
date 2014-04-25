module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggers, through: :tags, class_name: 'User'
    has_many :tags, as: :taggable, dependent: :destroy
  end

  def tag_count
    tags.count
  end
end
