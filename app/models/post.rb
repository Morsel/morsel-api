# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`title`**       | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`creator_id`**  | `integer`          |
#

class Post < ActiveRecord::Base
  belongs_to :creator, foreign_key: 'creator_id', class_name: 'User'
  has_and_belongs_to_many :morsels
end
