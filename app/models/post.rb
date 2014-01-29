# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`title`**        | `string(255)`      |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`creator_id`**   | `integer`          |
# **`cached_slug`**  | `string(255)`      |
#

class Post < ActiveRecord::Base
  is_sluggable :title

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :morsel_posts
  has_many :morsels, -> { order('morsel_posts.sort_order ASC') }, through: :morsel_posts
end
