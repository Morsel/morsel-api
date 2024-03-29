# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                              | Type               | Attributes
# --------------------------------- | ------------------ | ---------------------------
# **`id`**                          | `integer`          | `not null, primary key`
# **`title`**                       | `string(255)`      |
# **`created_at`**                  | `datetime`         |
# **`updated_at`**                  | `datetime`         |
# **`creator_id`**                  | `integer`          |
# **`cached_slug`**                 | `string(255)`      |
# **`deleted_at`**                  | `datetime`         |
# **`draft`**                       | `boolean`          | `default(TRUE), not null`
# **`published_at`**                | `datetime`         |
# **`primary_item_id`**             | `integer`          |
# **`photo`**                       | `string(255)`      |
# **`photo_content_type`**          | `string(255)`      |
# **`photo_file_size`**             | `string(255)`      |
# **`photo_updated_at`**            | `datetime`         |
# **`mrsl`**                        | `hstore`           |
# **`place_id`**                    | `integer`          |
# **`template_id`**                 | `integer`          |
# **`likes_count`**                 | `integer`          | `default(0), not null`
# **`cached_url`**                  | `string(255)`      |
# **`summary`**                     | `text`             |
# **`tagged_users_count`**          | `integer`          | `default(0), not null`
# **`publishing`**                  | `boolean`          | `default(FALSE)`
# **`cached_primary_item_photos`**  | `hstore`           |
#

class Morsel < ActiveRecord::Base
  include Authority::Abilities,
          ActivitySubscribeable,
          Feedable,
          Likeable,
          Mrslable,
          PgSearch,
          PhotoUploadable,
          Taggable,
          TimelinePaginateable,
          UserCreatable

  # ActivitySubscribeable
  def self.activity_subscription_actions; %w(like) end

  acts_as_paranoid
  has_paper_trail
  is_sluggable :title
  alias_attribute :slug, :cached_slug

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  alias_attribute :user, :creator
  alias_attribute :user_id, :creator_id

  accepts_nested_attributes_for :feed_item

  belongs_to :place, inverse_of: :morsels

  has_many :collection_morsels, dependent: :destroy
  has_many :collections, through: :collection_morsels, source: :collection

  has_many :items, -> { order(Item.arel_table[:sort_order].asc) }, dependent: :destroy
  belongs_to :primary_item, class_name: 'Item'

  has_many :morsel_user_tags, dependent: :destroy
  has_many :tagged_users, through: :morsel_user_tags, source: :user

  before_save :update_cached_primary_item_photos,
              :update_published_at_if_necessary,
              :update_url

  after_destroy :update_counter_caches
  after_save  :update_counter_caches,
              :update_tags

  mount_uploader :photo, MorselPhotoUploader

  validate :primary_item_belongs_to_morsel

  validates :title,
            length: { maximum: 70 },
            allow_nil: true

  pg_search_scope :full_search,
                  against: {
                    title: 'A',
                    summary: 'B'
                  },
                  associated_against: {
                    items: {
                      description: 'C'
                    }
                  },
                  order_within_rank: 'published_at DESC'

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :with_drafts, -> (include_drafts = true) { where(draft: false) unless include_drafts }
  scope :where_place_id, -> (place_id) { where(place_id: place_id) unless place_id.nil? }
  scope :where_collection_id, -> (collection_id) { joins(:collection_morsels).where(CollectionMorsel.arel_table[:collection_id].eq(collection_id)) unless collection_id.nil? }
  scope :where_creator_id, -> (creator_id) { where(creator_id: creator_id) unless creator_id.nil? }
  scope :where_tagged_user_id, -> (tagged_user_id) { includes(:morsel_user_tags).where(MorselUserTag.arel_table[:user_id].eq(tagged_user_id)) unless tagged_user_id.nil? }
  scope :where_creator_id_or_tagged_user_id, -> (creator_id_or_tagged_user_id) { includes(:morsel_user_tags).where(Morsel.arel_table[:creator_id].eq(creator_id_or_tagged_user_id).or(MorselUserTag.arel_table[:user_id].eq(creator_id_or_tagged_user_id))).references(:morsel_user_tags) unless creator_id_or_tagged_user_id.nil? }

  concerning :Caching do
    def cache_key
      [super, CachedModelDecorator.new(self).cache_key_for_has_many(:items)].join('/')
    end
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

  def url_for_item(item)
    "#{url}/#{items.find_index(item) + 1}" if item.id?
  end

  def tagged_user?(user)
    tagged_users.include? user
  end

  def tagged_users?
    tagged_users_count > 0
  end

  def url
    cached_url || update_url
  end

  def primary_item_photos
    cached_primary_item_photos || ( primary_item_id.present? ? primary_item.photos : nil)
  end

  private

  def primary_item_belongs_to_morsel
    errors.add(:primary_item, 'does not belong to this Morsel') if primary_item_id && !item_ids.include?(primary_item_id)
  end

  def update_counter_caches
    self.creator.update drafts_count: Morsel.drafts.where(creator_id: creator_id).count if creator
  end

  def update_cached_primary_item_photos
    if primary_item_id_changed?
      self.cached_primary_item_photos = primary_item ? primary_item.photos : nil
    end
  end

  def update_published_at_if_necessary
    self.published_at = DateTime.now if !published_at && !draft
  end

  def update_url
    self.cached_url = "#{Settings.morsel.web_url}/#{creator.username}/#{id}-#{cached_slug}" if (creator && id?) && (cached_url.nil? || creator_id_changed? || title_changed?)
  end

  def update_tags
    UpdateMorselTagsWorker.perform_async(morsel_id:id) if summary_changed?
  end
end
