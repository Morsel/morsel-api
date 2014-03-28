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
# **`nonce`**               | `string(255)`      |
# **`photo_processing`**    | `boolean`          |
# **`post_id`**             | `integer`          |
# **`sort_order`**          | `integer`          |
#

class Morsel < ActiveRecord::Base
  include Authority::Abilities
  include PhotoUploadable
  include TimelinePaginateable
  include UserCreatable

  acts_as_paranoid

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :activities, as: :subject, dependent: :destroy
  has_many :commenters, through: :comments, source: :user
  has_many :comments, dependent: :destroy
  has_many :likers, through: :likes, source: :user
  has_many :likes, dependent: :destroy
  belongs_to :post, touch: true

  before_save :check_sort_order

  mount_uploader :photo, MorselPhotoUploader
  process_in_background :photo

  scope :feed, -> { includes(:creator, :post) }

  validates :post, presence: true

  def like_count
    likes.count
  end

  def comment_count
    comments.count
  end

  def facebook_message
    message = post_title_with_description
    message << url

    message.normalize
  end

  def twitter_message
    message = post_title_with_description
    message.twitter_string(url)
  end

  def url
    # https://eatmorsel.com/marty/1-my-first-post/2
    "#{Settings.morsel.web_url}/#{creator.username}/#{post.id}-#{post.cached_slug}/#{post.morsels.find_index(self) + 1}"
  end

  def photos_hash
    if photo_url.present?
      {
        _50x50:   photo_url(:_50x50),
        _80x80:   photo_url(:_80x80),
        _100x100: photo_url(:_100x100),
        _240x240: photo_url(:_240x240),
        _320x320: photo_url(:_320x320),
        _480x480: photo_url(:_480x480),
        _640x640: photo_url(:_640x640),
        _992x992: photo_url(:_992x992)
      }
    end
  end

  def post_title_with_description
    message = ''
    message << "#{post.title}: " if post && post.title?
    message << "#{description} " if description.present?
  end

  private

  def check_sort_order
    if self.sort_order_changed?
      existing_morsel = Morsel.find_by(post: self.post, sort_order: self.sort_order)

      # If the sort_order has been taken, increment the sort_order for every morsel >= sort_order
      self.post.morsels.where('sort_order >= ?', self.sort_order).update_all('sort_order = sort_order + 1') if existing_morsel
    end

    self.sort_order = generate_sort_order if self.sort_order.blank?
  end

  def generate_sort_order
    last_sort_order = post.morsels.maximum(:sort_order)
    if last_sort_order.present?
      last_sort_order + 1
    else
      1
    end
  end
end
