# ## Schema Information
#
# Table name: `morsel_tagged_users`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`morsel_id`**   | `integer`          |
# **`user_id`**     | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class MorselTaggedUser < ActiveRecord::Base
  include Authority::Abilities

  acts_as_paranoid

  belongs_to :morsel
  belongs_to :user

  validates :morsel_id, uniqueness: { scope: [:user_id], conditions: -> { where(deleted_at: nil) } }
  validates :morsel, presence: true
  validates :user, presence: true
end
