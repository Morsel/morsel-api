# ## Schema Information
#
# Table name: `activities`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`subject_id`**    | `integer`          |
# **`subject_type`**  | `string(255)`      |
# **`action_id`**     | `integer`          |
# **`action_type`**   | `string(255)`      |
# **`creator_id`**    | `integer`          |
# **`deleted_at`**    | `datetime`         |
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
# **`hidden`**        | `boolean`          | `default(FALSE)`
#

class Activity < ActiveRecord::Base
  include Authority::Abilities,
          TimelinePaginateable

  acts_as_paranoid
  belongs_to :action, polymorphic: true
  belongs_to :subject, polymorphic: true
  belongs_to :creator, class_name: 'User'
  has_many :notifications, as: :payload, dependent: :destroy

  def activity_subscriptions
    ActivitySubscription.subscriptions_for_activity(self)
  end

  def active_activity_subscribers
    ActivitySubscription.active_subscribers_for_activity(self)
  end
end
