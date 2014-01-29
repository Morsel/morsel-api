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
# **`draft`**               | `boolean`          | `default(FALSE), not null`
#

class Morsel < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :comments
  has_many :likers, through: :likes, source: :user
  has_many :likes
  has_many :morsel_posts
  has_many :posts, through: :morsel_posts

  include PhotoUploadable

  mount_uploader :photo, MorselPhotoUploader

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }

  before_save :update_photo_attributes

  validate :description_or_photo_present?

  def change_sort_order_for_post_id(post_id, new_sort_order)
    MorselPost.increment_sort_order_for_post_id(post_id, new_sort_order)
    set_new_sort_order_for_post_id(post_id, new_sort_order)
  end

  def sort_order_for_post_id(post_id)
    morsel_posts.where(post_id: post_id).first.sort_order
  end

  def facebook_message(post)
    message = ''
    message << "#{post.title}: " if post.title?
    message << "#{description} " if description.present?
    message << url(post)

    message.normalize
  end

  def twitter_message(post)
    message = ''
    message << "#{post.title}: " if post.title?
    message << "#{description} " if description.present?

    message.twitter_string(url(post))
  end

  def url(post)
    # https://eatmorsel.com/marty/1/my-first-post/2
    "#{Settings.morsel.web_url}/#{creator.username}/#{post.id}/#{post.cached_slug}/#{post.morsels.find_index(self) + 1}"
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
