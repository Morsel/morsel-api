# ## Schema Information
#
# Table name: `devices`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`user_id`**     | `integer`          |
# **`name`**        | `string(255)`      |
# **`token`**       | `string(255)`      |
# **`model`**       | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#

class Device < ActiveRecord::Base
  include TimelinePaginateable
  acts_as_paranoid

  belongs_to :user

  validates :user, presence: true
  validates :name, presence: true
  validates :token, presence: true
  validates :model, presence: true
end
