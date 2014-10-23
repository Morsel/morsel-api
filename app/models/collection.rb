# ## Schema Information
#
# Table name: `collections`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`title`**        | `string(255)`      |
# **`description`**  | `text`             |
# **`user_id`**      | `integer`          |
# **`place_id`**     | `integer`          |
# **`deleted_at`**   | `datetime`         |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`cached_slug`**  | `string(255)`      |
#

class Collection < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable, UserCreatable

  acts_as_paranoid
  is_sluggable :title
  alias_attribute :slug, :cached_slug

  belongs_to :user
  belongs_to :place

  has_many :collection_morsels, dependent: :destroy
  has_many :morsels, through: :collection_morsels, source: :morsel

  validates :title,
            presence: true,
            length: { maximum: 50 }
  validates :user, presence: true
end
