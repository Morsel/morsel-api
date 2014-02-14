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
  # process_in_background :photo

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }

  before_save :update_photo_attributes

  validate :description_or_photo_present?

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
    # https://eatmorsel.com/marty/1-my-first-post/2
    "#{Settings.morsel.web_url}/#{creator.username}/#{post.id}-#{post.cached_slug}/#{post.morsels.find_index(self) + 1}"
  end

  def photos_hash
    if photo_url.present?
      {
        _104x104: photo_url(:_104x104),
        _208x208: photo_url(:_208x208),
        _320x214: photo_url(:_320x214),
        _640x428: photo_url(:_640x428),
        _640x640: photo_url(:_640x640)
      }
    end
  end


  private

  def description_or_photo_present?
    if description.blank? && (photo.blank? && photo_url.blank?)
      errors.add(:base, 'Description or photo is required.')
      return false
    end
  end
end
