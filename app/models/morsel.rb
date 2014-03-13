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
#

class Morsel < ActiveRecord::Base
  include Authority::Abilities
  include PhotoUploadable
  include TimelinePaginateable
  include UserCreatable

  acts_as_paranoid

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :activities, as: :subject
  has_many :comments
  has_many :likers, through: :likes, source: :user
  has_many :likes
  has_many :morsel_posts, dependent: :destroy
  has_many :posts, through: :morsel_posts, dependent: :destroy

  mount_uploader :photo, MorselPhotoUploader
  process_in_background :photo

  scope :feed, -> { includes(:creator, :morsel_posts, :posts) }

  after_save :update_posts_updated_at

  validates :nonce, uniqueness: { scope: :creator_id }, :if => :nonce?

  def sort_order_for_post_id(post_id)
    morsel_posts.find_by(post_id: post_id).sort_order
  end

  def first_post_title_with_description
    post_title_with_description(posts.first)
  end

  def facebook_message(post)
    message = post_title_with_description(post)
    message << url(post)

    message.normalize
  end

  def twitter_message(post)
    message = post_title_with_description(post)

    message.twitter_string(url(post))
  end

  def url(post)
    # https://eatmorsel.com/marty/1-my-first-post/2
    "#{Settings.morsel.web_url}/#{creator.username}/#{post.id}-#{post.cached_slug}/#{post.morsels.find_index(self) + 1}"
  end

  def photos_hash
    if photo_url.present?
      {
        _50x50: photo_url(:_50x50),
        _100x100: photo_url(:_100x100),
        _320x320: photo_url(:_320x320),
        _640x640: photo_url(:_640x640)
      }
    end
  end

  private

  def post_title_with_description(post)
    message = ''
    message << "#{post.title}: " if post && post.title?
    message << "#{description} " if description.present?
  end

  def update_posts_updated_at
    # Faster than doing posts.each(&:touch)
    posts.update_all(updated_at: updated_at) if updated_at
  end
end
