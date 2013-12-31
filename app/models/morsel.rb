# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`description`**  | `text`             |
# **`like_count`**   | `integer`          | `default(0), not null`
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`user_id`**      | `integer`          |
#

class Morsel < ActiveRecord::Base
  belongs_to :user
end
