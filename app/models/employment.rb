# ## Schema Information
#
# Table name: `employments`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`place_id`**    | `integer`          |
# **`user_id`**     | `integer`          |
# **`title`**       | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
#

class Employment < ActiveRecord::Base
  include Authority::Abilities, UserCreatable
  acts_as_paranoid

  belongs_to :place
  belongs_to :user

  validates :user_id, uniqueness: { scope: [:deleted_at, :place_id], conditions: -> { where(deleted_at: nil) } }
end
