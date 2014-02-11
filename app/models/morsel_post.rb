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
  belongs_to :post

  before_save :ensure_sort_order

  validates :morsel_id,  uniqueness: { scope: :post_id }
  validates :sort_order, uniqueness: { scope: :post_id }

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
