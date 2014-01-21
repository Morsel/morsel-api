# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`description`**         | `text`             |
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`deleted_at`**          | `datetime`         |
#

class Morsel < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :creator, foreign_key: 'creator_id', class_name: 'User'
  has_many :liking_users, through: :likes, source: :user
  has_many :likes
  has_many :morsel_posts
  has_many :posts, through: :morsel_posts

  include PhotoUploadable

  mount_uploader :photo, MorselPhotoUploader

  before_save :update_photo_attributes

  validate :description_or_photo_present?

  def change_sort_order_for_post_id(post_id, new_sort_order)
    MorselPost.increment_sort_order_for_post_id(post_id, new_sort_order)
    set_new_sort_order_for_post_id(post_id, new_sort_order)
  end

  def sort_order_for_post_id(post_id)
    morsel_posts.where(post_id: post_id).first.sort_order
  end

  def twitter_message(post)
    message = ""
    message << "#{post.title}: " if post.title.present?
    message << description if description.present?

    message.twitter_string(url(post))
  end

  def url(post)
    "#{Settings.morsel.web_url}/posts/#{creator.username}/posts/#{post.id}/#{id}"
  end

  private

  def description_or_photo_present?
    if description.blank? && photo.blank?
      errors.add(:description_or_photo, 'is required.')
      return false
    end
  end

  def set_new_sort_order_for_post_id(post_id, new_sort_order)
    morsel_post = morsel_posts.where(post_id: post_id).first
    morsel_post.sort_order = new_sort_order
    morsel_post.save
  end
end
