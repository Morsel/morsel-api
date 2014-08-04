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
# **`mrsl`**                | `hstore`           |
# **`place_id`**            | `integer`          |
#

class Morsel < ActiveRecord::Base
  include Authority::Abilities, Feedable, Mrslable, PhotoUploadable, TimelinePaginateable, UserCreatable

  acts_as_paranoid
  is_sluggable :title
  alias_attribute :slug, :cached_slug

  belongs_to  :creator, class_name: 'User', foreign_key: 'creator_id'
  alias_attribute :user, :creator
  alias_attribute :user_id, :creator_id

  belongs_to  :place

  has_many    :items, -> { order(Item.arel_table[:sort_order].asc) }, dependent: :destroy
  belongs_to  :primary_item, class_name: 'Item'

  before_save :update_published_at_if_necessary

  mount_uploader :photo, MorselPhotoUploader
  process_in_background :photo

  validate  :primary_item_belongs_to_morsel

  validates :title,
            presence: true,
            length: { maximum: 50 }

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :with_drafts, -> (include_drafts = true) { where(draft: false) unless include_drafts }

  def total_like_count
    items.map(&:like_count).reduce(:+)
  end

  def total_comment_count
    items.map(&:comment_count).reduce(:+)
  end

  # Since there are no 'versions' for a Morsel photo (the collage), override the photos method from PhotoUploadable and return it as the default size.
  def photos
    if photo?
      {
        _800x600: photo_url
      }
    end
  end

  def facebook_message
    "\"#{title}\" from #{creator.full_name} on Morsel #{facebook_mrsl}".normalize
  end

  def twitter_message
    if TwitterAuthenticatedUserDecorator.new(creator).twitter_username.present?
      twitter_username_or_full_name = "@#{TwitterAuthenticatedUserDecorator.new(creator).twitter_username}"
    else
      twitter_username_or_full_name = creator.full_name
    end
    "\"#{title}\" from #{twitter_username_or_full_name}".twitter_string("on @#{Settings.morsel.twitter_username} #{twitter_mrsl}")
  end

  def url
    # https://eatmorsel.com/marty/1-my-first-morsel
    "#{Settings.morsel.web_url}/#{creator.username}/#{id}-#{cached_slug}"
  end

  def url_for_item(item)
    "#{url}/#{items.find_index(item) + 1}"
  end

  def publish!(options = {})
    # TODO: Crap out if already published

    if update draft: false
      PublishMorselWorker.perform_async(
        morsel_id: self.id,
        place_id: self.place_id,
        user_id: self.user_id,
        post_to_facebook: options[:post_to_facebook],
        post_to_twitter: options[:post_to_twitter]
      )
      true
    else
      false
    end
  end

  def unpublish!
    # TODO: Crap out if not already published
    feed_item.destroy
    update draft: true, published_at: nil
  end

  private

  def primary_item_belongs_to_morsel
    errors.add(:primary_item, 'does not belong to this Morsel') if primary_item_id && !item_ids.include?(primary_item_id)
  end

  def update_published_at_if_necessary
    self.published_at = DateTime.now if !published_at && !draft
  end
end
