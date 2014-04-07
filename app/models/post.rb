# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`id`**                 | `integer`          | `not null, primary key`
# **`title`**              | `string(255)`      |
# **`created_at`**         | `datetime`         |
# **`updated_at`**         | `datetime`         |
# **`creator_id`**         | `integer`          |
# **`cached_slug`**        | `string(255)`      |
# **`deleted_at`**         | `datetime`         |
# **`draft`**              | `boolean`          | `default(FALSE), not null`
# **`published_at`**       | `datetime`         |
# **`primary_morsel_id`**  | `integer`          |
#

class Post < ActiveRecord::Base
  include Authority::Abilities
  include Feedable
  include PhotoUploadable
  include TimelinePaginateable
  include UserCreatable

  acts_as_paranoid
  is_sluggable :title

  belongs_to  :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many    :morsels, -> { order('sort_order ASC') }, dependent: :destroy

  before_save :update_published_at_if_necessary

  mount_uploader :photo, PostPhotoUploader
  process_in_background :photo

  validate  :primary_morsel_belongs_to_post

  validates :title,
            presence: true,
            length: { maximum: 50 }

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :include_drafts, -> (include_drafts) { where(draft: false) unless include_drafts.present? }

  def total_like_count
     morsels.map(&:like_count).reduce(:+)
  end

  def total_comment_count
     morsels.map(&:comment_count).reduce(:+)
  end

  def primary_morsel
    morsels.find primary_morsel_id
  end

  def photos_hash
    if photo_url.present?
      {
        _400x300: photo_url,
      }
    end
  end

  def facebook_message
    "#{title}: #{url}".normalize
  end

  def twitter_message
    "#{title}: ".twitter_string(url)
  end

  def url
    # https://eatmorsel.com/marty/1-my-first-post
    "#{Settings.morsel.web_url}/#{creator.username}/#{id}-#{cached_slug}"
  end

  def url_for_morsel(morsel)
    "#{url}/#{morsels.find_index(morsel) + 1}"
  end

  private

  def primary_morsel_belongs_to_post
    errors.add(:primary_morsel, 'does not belong to this Post') if primary_morsel_id && !morsel_ids.include?(primary_morsel_id)
  end

  def update_published_at_if_necessary
    self.published_at = DateTime.now if !published_at && !draft
  end
end
