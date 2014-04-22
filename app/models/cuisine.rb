# ## Schema Information
#
# Table name: `cuisines`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`name`**        | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Cuisine < ActiveRecord::Base
  include TimelinePaginateable
  acts_as_paranoid

  has_many :cuisine_users
  has_many :users, through: :cuisine_users

  validates :name,
            presence: true
end
