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
  acts_as_paranoid
  is_sluggable :title

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :morsel_posts
  has_many :morsels, -> { order('morsel_posts.sort_order ASC') }, through: :morsel_posts

  include TimelinePaginateable

  def set_sort_order_for_morsel(morsel_id, new_sort_order)
    morsel_posts_to_increment = morsel_posts.where('sort_order >= ?', new_sort_order)
    morsel_posts_to_increment.update_all('sort_order = sort_order + 1')

    morsel_post = morsel_posts.find_by(post_id: id, morsel_id: morsel_id)
    morsel_post.sort_order = new_sort_order
    morsel_post.save
  end
end
