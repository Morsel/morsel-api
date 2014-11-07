# ## Schema Information
#
# Table name: `follows`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`follower_id`**      | `integer`          |
# **`followable_id`**    | `integer`          |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`followable_type`**  | `string(255)`      |
# **`deleted_at`**       | `datetime`         |
#

class Follow < ActiveRecord::Base
  include Authority::Abilities,
          Activityable,
          UserCreatable

  def self.activity_notification; true end
  def activity_subject; followable end

  acts_as_paranoid

  belongs_to :followable, polymorphic: true
  belongs_to :follower, class_name: 'User'
  alias_attribute :creator, :follower
  alias_attribute :user, :follower

  after_destroy :update_counter_caches
  after_save :update_counter_caches

  validates :follower_id, uniqueness: { scope: [:followable_id, :followable_type], conditions: -> { where(deleted_at: nil) } }
  validates :followable, presence: true

  def followable_type=(sType)
    base_class = sType.constantize.try(:base_class)
    if base_class
      super(base_class.to_s)
    else
      super(sType)
    end
  end

  private

  def update_counter_caches
    self.follower.update followed_users_count: Follow.where(follower_id:follower_id, followable_type:followable_type).count if followable_type == 'User'
    self.followable.update followers_count: Follow.where(followable_id:followable_id, followable_type:followable_type).count
  end
end
