# ## Schema Information
#
# Table name: `morsel_posts`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`morsel_id`**   | `integer`          |
# **`post_id`**     | `integer`          |
# **`sort_order`**  | `integer`          |
# **`id`**          | `integer`          | `not null, primary key`
#

class MorselPost < ActiveRecord::Base
  belongs_to :morsel
  belongs_to :post

  before_save :ensure_sort_order

  validates :morsel_id,  uniqueness: { scope: :post_id }
  validates :sort_order, uniqueness: { scope: :post_id }

  def self.increment_sort_order_for_post_id(post_id, starting_sort_order = 0)
    MorselPost
      .where(post_id: post_id)
      .where('sort_order >= ?', starting_sort_order)
      .update_all('sort_order = sort_order + 1')
  end

  private

  def ensure_sort_order
    self.sort_order = generate_sort_order if sort_order.blank?
  end

  def generate_sort_order
    last_sort_order = MorselPost.where(post_id: post_id).maximum(:sort_order)
    if last_sort_order.present?
      last_sort_order + 1
    else
      1
    end
  end
end
