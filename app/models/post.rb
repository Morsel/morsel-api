# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`title`**         | `string(255)`      |
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
# **`creator_id`**    | `integer`          |
# **`cached_slug`**   | `string(255)`      |
# **`deleted_at`**    | `datetime`         |
# **`draft`**         | `boolean`          | `default(FALSE), not null`
# **`published_at`**  | `datetime`         |
#

class Post < ActiveRecord::Base
  include Authority::Abilities
  include TimelinePaginateable
  include UserCreatable

  acts_as_paranoid
  is_sluggable :title

  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many :morsels, -> { order('sort_order ASC') }, dependent: :destroy

  before_save :update_published_at_if_necessary

  validates :title,
            presence: true,
            length: { maximum: 50 }

  scope :drafts, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :include_drafts, -> (include_drafts) { where(draft: false) unless include_drafts.present? }

  private

  def update_published_at_if_necessary
    self.published_at = DateTime.now if !published_at && !draft
  end
end
