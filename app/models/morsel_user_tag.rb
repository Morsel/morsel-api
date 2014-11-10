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

  validates :morsel_id, uniqueness: { scope: [:user_id], conditions: -> { where(deleted_at: nil) } }
  validates :morsel, presence: true
  validates :user, presence: true
end
