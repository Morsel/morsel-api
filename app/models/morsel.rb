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

  has_many :associated_morsel, class_name: 'AssociationRequest', primary_key: 'creator_id', foreign_key: 'associated_user_id'

  has_many :morsel_morsel_keywords
  has_many :morsel_keywords, through: :morsel_morsel_keywords

  has_many :morsel_morsel_topics
  has_many :morsel_topics, through: :morsel_morsel_topics

  has_many :associated_morsels, class_name: 'AssociatedMorsel',foreign_key: 'morsel_id',:dependent=> :destroy
  has_many :morsel_hosts,through: :associated_morsels, source: :hostuser

  # has_many :subscriptions
  # has_many :subscribers, through: :subscriptions, source: :user


  has_many :email_logs
  has_many :sendemaillogs, through: :email_logs, source: :user

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

  scope :drafts, -> { where(draft: true ) }
  scope :published, -> { where(draft: false)}
  scope :submitted, -> { where('draft= ? OR is_submit= ?',false,true)}
  scope :where_keyword_id, -> (keyword_id) {  joins(:morsel_keywords).where(MorselKeyword.arel_table[:id].eq(keyword_id)) unless keyword_id.blank?}
  scope :where_topic_id, -> (topic_id) {  joins(:morsel_topics).where(MorselTopic.arel_table[:id].eq(topic_id)) unless topic_id.blank?}
  scope :with_drafts, -> (include_drafts = true) { where(draft: false) unless include_drafts }
  scope :where_place_id, -> (place_id) { where(place_id: place_id) unless place_id.nil? }
  scope :where_collection_id, -> (collection_id) { joins(:collection_morsels).where(CollectionMorsel.arel_table[:collection_id].eq(collection_id)) unless collection_id.nil? }
  scope :where_creator_id, -> (creator_id) { where(creator_id: creator_id) unless creator_id.nil? }
  scope :where_tagged_user_id, -> (tagged_user_id) { includes(:morsel_user_tags).where(MorselUserTag.arel_table[:user_id].eq(tagged_user_id)) unless tagged_user_id.nil? }
  scope :where_creator_id_or_tagged_user_id, -> (creator_id_or_tagged_user_id,morsel_ids = []) { includes(:morsel_user_tags).where(Morsel.arel_table[:creator_id].in(creator_id_or_tagged_user_id).or(MorselUserTag.arel_table[:user_id].in(creator_id_or_tagged_user_id)).or(Morsel.arel_table[:id].in(morsel_ids))).references(:morsel_user_tags) unless creator_id_or_tagged_user_id.nil? }
  scope :where_associated_user, -> (associated_user) { joins(:associated_morsel).where(Morsel.arel_table[:created_at].gteq(AssociationRequest.arel_table[:created_at]).and(Morsel.arel_table[:creator_id].in(associated_user))) unless associated_user.nil? }
  scope :morsel_ids_associate_with_host, -> (host_id) { joins(:associated_morsels).where(AssociatedMorsel.arel_table[:host_id].eq(host_id)) unless host_id.nil? }
  concerning :Caching do
    def cache_key
      [super, [CachedModelDecorator.new(self).cache_key_for_has_many(:items),CachedModelDecorator.new(self).cache_key_for_has_many(:morsel_keywords)].join("-")  ].join('/')
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
    cached_primary_item_photos || ( primary_item_id.present? ? primary_item ? primary_item.photos : nil : nil)
  end

  def capitalize_name(string_part)
    string_part.split.map(&:capitalize).join(' ') if string_part
  end

  def host_info

    if user.profile.present?
      user_profile = user.profile
      {host_morsel_url:(!user_profile.host_url.blank? ? "http://#{user_profile.host_url.gsub(/^https?\:\/\//,"").gsub(/\/$/,"")}/morsel-info/?morselid=#{id}" : "https://www.eatmorsel.com/morsel-info/?morselid=#{id}"),host_logo:(user_profile.host_logo.blank? ? (cached_primary_item_photos.present? ? cached_primary_item_photos.symbolize_keys[:_640x640] : 'https://www.eatmorsel.com/assets/images/utility/placeholders/morsel-placeholder_640x640.jpg') : user_profile.host_logo), address: "#{capitalize_name(user_profile.company_name)}, #{user_profile.street_address}, #{capitalize_name(user_profile.city)}, #{user_profile.state.upcase} #{user_profile.zip}",preview_text: (!user_profile.preview_text.blank? ? user_profile.preview_text : 'Email is showing your subscribed morsel as well as latest morsel')}

    elsif user.recieved_association_requests.first.present?
      user_profile = user.recieved_association_requests.first.host.profile
      {host_morsel_url:(!user_profile.host_url.blank? ? "http://#{user_profile.host_url.gsub(/^https?\:\/\//,"").gsub(/\/$/,"")}/morsel-info/?morselid=#{id}" : "https://www.eatmorsel.com/morsel-info/?morselid=#{id}"),host_logo:(user_profile.host_logo.blank? ? (cached_primary_item_photos.present? ? cached_primary_item_photos.symbolize_keys[:_640x640] : 'https://www.eatmorsel.com/assets/images/utility/placeholders/morsel-placeholder_640x640.jpg') : user_profile.host_logo), address: "#{capitalize_name(user_profile.company_name)}, #{user_profile.street_address}, #{capitalize_name(user_profile.city)}, #{user_profile.state.upcase} #{user_profile.zip}",preview_text: (!user_profile.preview_text.blank? ? user_profile.preview_text : 'Email is showing your subscribed morsel as well as latest morsel')}

    end

  end

  def self.get_associated_users_morsels(host_id, pagination_params, pagination_key)
    # associated_morsels_ids = self.where_associated_user(approved_ids).map(&:id)
    # morsel_ids_associate_with_host = self.morsel_ids_associate_with_host(host_id).map(&:id)
    # morsel_ids = morsel_ids_associate_with_host.concat(associated_morsels_ids).uniq
    morsel_ids = self.morsel_ids_associate_with_host(host_id).map(&:id)
    morsels = self.includes(:items, :place, :creator)
                  .order(Morsel.arel_table[:published_at].desc)
                  .where_creator_id_or_tagged_user_id(host_id, morsel_ids)
                  .paginate(pagination_params, pagination_key)
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
