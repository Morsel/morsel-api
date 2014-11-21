# ## Schema Information
#
# Table name: `morsel_user_tags`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`morsel_id`**   | `integer`          |
# **`user_id`**     | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class MorselUserTag < ActiveRecord::Base
  include Authority::Abilities,
          Activityable

  def self.activity_hidden; true end
  def self.activity_notification; false end
  def activity_subject; morsel end
  def activity_creator; morsel.creator end

  acts_as_paranoid

  belongs_to :morsel, touch: true
  belongs_to :user

  after_destroy :update_counter_caches,
                :unsubscribe_tagged_user_from_morsel_items
  after_save :update_counter_caches
  after_commit :subscribe_tagged_user_to_morsel_items, on: :create

  validates :morsel_id, uniqueness: { scope: [:user_id], conditions: -> { where(deleted_at: nil) } }
  validates :morsel, presence: true
  validates :user, presence: true

  private

  def subscribe_tagged_user_to_morsel_items
    SubscribeUserToMorselItemsWorker.perform_async(
      morsel_id: morsel_id,
      user_id: user_id,
      actions: %w(comment),
      reason: 'tagged',
      active: false
    )
  end

  def unsubscribe_tagged_user_from_morsel_items
    UnsubscribeUserFromMorselItemsWorker.perform_async(
      morsel_id: morsel_id,
      user_id: user_id,
      actions: %w(comment),
      reason: 'tagged',
      active: false
    )
  end

  def update_counter_caches
    self.morsel.update tagged_users_count: MorselUserTag.where(morsel_id: morsel_id).count
  end
end
