# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`liker_id`**       | `integer`          |
# **`likeable_id`**    | `integer`          |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`likeable_type`**  | `string(255)`      |
#

class Like < ActiveRecord::Base
  include Authority::Abilities, UserCreatable

  include Activityable
  def self.activity_notification; true end
  def activity_subject; likeable end

  acts_as_paranoid

  after_destroy :update_counter_caches
  after_save :update_counter_caches

  belongs_to :likeable, polymorphic: true
  belongs_to :liker, class_name: 'User'
  alias_attribute :creator, :liker
  alias_attribute :user, :liker

  validates :liker_id, uniqueness: { scope: [:likeable_id, :likeable_type], conditions: -> { where(deleted_at: nil) } }
  validates :likeable, presence: true

  private

  def update_counter_caches
    self.likeable.update likes_count: Like.where(likeable_id:likeable_id, likeable_type:likeable_type).count unless likeable_type == 'Item'
  end
end
