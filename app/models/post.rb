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
  include TimelinePaginateable
  include UserCreatable

  acts_as_paranoid
  is_sluggable :title

  belongs_to  :creator, class_name: 'User', foreign_key: 'creator_id'
  has_many    :morsels, -> { order('sort_order ASC') }, dependent: :destroy

  before_save :update_published_at_if_necessary

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

  private

  def primary_morsel_belongs_to_post
    errors.add(:primary_morsel, 'does not belong to this Post') if primary_morsel_id && !morsel_ids.include?(primary_morsel_id)
  end

  def update_published_at_if_necessary
    self.published_at = DateTime.now if !published_at && !draft
  end
end
