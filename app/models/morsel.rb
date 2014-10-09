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
# **`template_id`**         | `integer`          |
#

class Morsel < ActiveRecord::Base
  include Authority::Abilities, Feedable, Likeable, Mrslable, PhotoUploadable, TimelinePaginateable, UserCreatable

  acts_as_paranoid
  is_sluggable :title
  alias_attribute :slug, :cached_slug

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  alias_attribute :user, :creator
  alias_attribute :user_id, :creator_id

  accepts_nested_attributes_for :feed_item

  belongs_to :place

  has_many :items, -> { order(Item.arel_table[:sort_order].asc) }, dependent: :destroy
  belongs_to :primary_item, class_name: 'Item'

  has_many :morsel_user_tags, dependent: :destroy
  has_many :tagged_users, through: :morsel_user_tags, source: :user

  before_save :update_published_at_if_necessary

  mount_uploader :photo, MorselPhotoUploader

  validate :primary_item_belongs_to_morsel

  validates :title,
            length: { maximum: 50 }

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :with_drafts, -> (include_drafts = true) { where(draft: false) unless include_drafts }
  scope :where_place_id, -> (place_id) { where(place_id: place_id) unless place_id.nil? }
  scope :where_creator_id, -> (creator_id) { where(creator_id: creator_id) unless creator_id.nil? }
  scope :where_tagged_user_id, -> (tagged_user_id) { includes(:morsel_user_tags).where(MorselUserTag.arel_table[:user_id].eq(tagged_user_id)) unless tagged_user_id.nil? }
  scope :where_creator_id_or_tagged_user_id, -> (creator_id_or_tagged_user_id) { includes(:morsel_user_tags).where(Morsel.arel_table[:creator_id].eq(creator_id_or_tagged_user_id).or(MorselUserTag.arel_table[:user_id].eq(creator_id_or_tagged_user_id))).references(:morsel_user_tags) unless creator_id_or_tagged_user_id.nil? }

  def total_like_count
    items.map(&:like_count).reduce(:+)
  end

  def total_comment_count
    items.map(&:comment_count).reduce(:+)
  end

  def item_count
    items.count
  end

  # Since there are no 'versions' for a Morsel photo (the collage), override the photos method from PhotoUploadable and return it as the default size.
  def photos
    return unless photo?
    {
      _840x420: photo_url,
      _800x600: photo_url
    }
  end

  def url
    # https://eatmorsel.com/marty/1-my-first-morsel
    "#{Settings.morsel.web_url}/#{creator.username}/#{id}-#{cached_slug}" if creator.username
  end

  def url_for_item(item)
    "#{url}/#{items.find_index(item) + 1}"
  end

  def tagged_user?(user)
    tagged_users.include? user
  end

  def tagged_users?
    morsel_user_tags.count > 0
  end

  private

  def primary_item_belongs_to_morsel
    errors.add(:primary_item, 'does not belong to this Morsel') if primary_item_id && !item_ids.include?(primary_item_id)
  end

  def update_published_at_if_necessary
    self.published_at = DateTime.now if !published_at && !draft
  end
end
