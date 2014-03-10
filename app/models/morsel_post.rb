# ## Schema Information
#
# Table name: `morsel_posts`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`morsel_id`**   | `integer`          |
# **`post_id`**     | `integer`          |
# **`sort_order`**  | `integer`          |
#

class MorselPost < ActiveRecord::Base
  belongs_to :morsel
  belongs_to :post, touch: true

  before_save :check_sort_order

  validates :morsel_id,  uniqueness: { scope: :post_id }

  private

  def check_sort_order
    if self.sort_order_changed?
      existing_morsel_post = MorselPost.find_by(post: self.post, sort_order: self.sort_order)

      # If the sort_order has been taken, increment the sort_order for every morsel_post >= sort_order
      self.post.morsel_posts.where('sort_order >= ?', self.sort_order).update_all('sort_order = sort_order + 1') if existing_morsel_post
    end

    self.sort_order = generate_sort_order if self.sort_order.blank?
  end

  def generate_sort_order
    last_sort_order = MorselPost.where(post: post).maximum(:sort_order)
    if last_sort_order.present?
      last_sort_order + 1
    else
      1
    end
  end
end
