# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`user_id`**     | `integer`          |
# **`morsel_id`**   | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Like < ActiveRecord::Base
  acts_as_paranoid

  validates_uniqueness_of :user_id, :scope => :morsel_id

  belongs_to :morsel
  belongs_to :user
end
