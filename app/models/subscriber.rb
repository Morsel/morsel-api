# ## Schema Information
#
# Table name: `subscribers`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`email`**       | `string(255)`      |
# **`url`**         | `string(255)`      |
# **`source_url`**  | `string(255)`      |
# **`role`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Subscriber < ActiveRecord::Base
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false }
end
