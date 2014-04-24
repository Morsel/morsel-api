# ## Schema Information
#
# Table name: `items`
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
# **`morsel_id`**           | `integer`          |
# **`sort_order`**          | `integer`          |
#

class Item < ActiveRecord::Base
  include Authority::Abilities, Commentable, Likeable, PhotoUploadable, TimelinePaginateable, UserCreatable

  acts_as_paranoid

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :activities, as: :subject, dependent: :destroy
  belongs_to :morsel, touch: true

  before_destroy :nullify_primary_item_id_if_primary_item_on_morsel
  before_save :check_sort_order

  mount_uploader :photo, ItemPhotoUploader
  process_in_background :photo

  scope :feed, -> { includes(:creator, :morsel) }

  validates :morsel, presence: true

  def url
    # https://eatmorsel.com/marty/1-my-first-morsel/2
    "#{morsel.url_for_item(self)}"
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

  def morsel_title_with_description
    message = ''
    message << "#{morsel.title}: " if morsel && morsel.title?
    message << "#{description} " if description.present?
  end

  private

  def check_sort_order
    if self.sort_order_changed?
      existing_item = Item.find_by(morsel: self.morsel, sort_order: self.sort_order)

      # If the sort_order has been taken, increment the sort_order for every item >= sort_order
      self.morsel.items.where('sort_order >= ?', self.sort_order).update_all('sort_order = sort_order + 1') if existing_item
    end

    self.sort_order = generate_sort_order if self.sort_order.blank?
  end

  def generate_sort_order
    last_sort_order = morsel.items.maximum(:sort_order)
    if last_sort_order.present?
      last_sort_order + 1
    else
      1
    end
  end

  def nullify_primary_item_id_if_primary_item_on_morsel
    self.morsel.update(primary_item_id: nil) if self.morsel.primary_item_id == self.id
  end
end
