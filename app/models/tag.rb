# ## Schema Information
#
# Table name: `tags`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`tagger_id`**      | `integer`          |
# **`keyword_id`**     | `integer`          |
# **`taggable_id`**    | `integer`          |
# **`taggable_type`**  | `string(255)`      |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
#

class Tag < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable, UserCreatable

  acts_as_paranoid

  belongs_to :taggable, polymorphic: true
  belongs_to :tagger, class_name: 'User'
  alias_attribute :creator, :tagger
  alias_attribute :user, :tagger
  belongs_to :keyword
  delegate :name, to: :keyword

  validates :keyword, presence: true
  validates :taggable, presence: true
end
