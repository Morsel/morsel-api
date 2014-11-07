module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggers, through: :tags, class_name: 'User'
    has_many :tags, as: :taggable, dependent: :destroy
    has_many :keywords, through: :tags

    def self.allowed_keyword_types; Keyword::VALID_TYPES end
  end

  def tag_count
    tags.count
  end
end
