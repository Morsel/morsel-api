# ## Schema Information
#
# Table name: `collection_morsels`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`collection_id`**  | `integer`          |
# **`morsel_id`**      | `integer`          |
# **`sort_order`**     | `integer`          |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`note`**           | `text`             |
#

class CollectionMorsel < ActiveRecord::Base
  include Authority::Abilities

  acts_as_paranoid

  belongs_to :collection
  belongs_to :morsel

  validates :collection,
    presence: true,
    uniqueness: { scope: [:morsel_id], conditions: -> { where(deleted_at: nil) } }

  validates :morsel,
    presence: true,
    uniqueness: { scope: [:collection_id], conditions: -> { where(deleted_at: nil) } }
end
