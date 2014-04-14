# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`title`**               | `string(255)`      |
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`cached_slug`**         | `string(255)`      |
# **`deleted_at`**          | `datetime`         |
# **`draft`**               | `boolean`          | `default(TRUE), not null`
# **`published_at`**        | `datetime`         |
# **`primary_item_id`**     | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
#

class Morsel < ActiveRecord::Base
  include Authority::Abilities
  include Feedable
  include Mrslable
  include PhotoUploadable
  include TimelinePaginateable
  include UserCreatable

  acts_as_paranoid
  is_sluggable :title

  belongs_to  :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many    :items, -> { order('sort_order ASC') }, dependent: :destroy

  before_save :update_published_at_if_necessary

  mount_uploader :photo, MorselPhotoUploader
  process_in_background :photo

  validate  :primary_item_belongs_to_morsel

  validates :title,
            presence: true,
            length: { maximum: 50 }

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :include_drafts, -> (include_drafts) { where(draft: false) unless include_drafts.present? }

  def total_like_count
     items.map(&:like_count).reduce(:+)
  end

  def total_comment_count
     items.map(&:comment_count).reduce(:+)
  end

  def primary_item
    items.find primary_item_id
  end

  def photos_hash
    if photo_url.present?
      {
        _400x300: photo_url,
      }
    end
  end

  def facebook_message
    "\"#{title}\" from #{creator.full_name} on Morsel #{facebook_mrsl}".normalize
  end

  def twitter_message
    twitter_username_or_full_name = TwitterUserDecorator.new(creator).twitter_username.presence || creator.full_name
    "\"#{title}\" from #{twitter_username_or_full_name} on @#{Settings.morsel.twitter_username}".twitter_string(twitter_mrsl)
  end

  def url
    # https://eatmorsel.com/marty/1-my-first-morsel
    "#{Settings.morsel.web_url}/#{creator.username}/#{id}-#{cached_slug}"
  end

  def url_for_item(item)
    "#{url}/#{items.find_index(item) + 1}"
  end

  private

  def primary_item_belongs_to_morsel
    errors.add(:primary_item, 'does not belong to this Morsel') if primary_item_id && !item_ids.include?(primary_item_id)
  end

  def update_published_at_if_necessary
    self.published_at = DateTime.now if !published_at && !draft
  end
end
