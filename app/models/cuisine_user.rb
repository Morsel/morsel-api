# ## Schema Information
#
# Table name: `cuisine_users`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`cuisine_id`**  | `integer`          |
# **`user_id`**     | `integer`          |
# **`deleted_at`**  | `datetime`         |
#

class CuisineUser < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :cuisine
  belongs_to :user
end
