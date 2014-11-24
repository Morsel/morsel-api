# ## Schema Information
#
# Table name: `activity_subscriptions`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`subscriber_id`**  | `integer`          |
# **`subject_id`**     | `integer`          |
# **`subject_type`**   | `string(255)`      |
# **`action`**         | `integer`          | `default(0)`
# **`reason`**         | `integer`          | `default(0)`
# **`active`**         | `boolean`          | `default(TRUE)`
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
#

class ActivitySubscription < ActiveRecord::Base
  enum action: %i(no_action comment like morsel_user_tag follow)
  enum reason: %i(no_reason created tagged commented)

  acts_as_paranoid

  belongs_to :subject, polymorphic: true
  belongs_to :subscriber, class_name: 'User'
  alias_attribute :user, :subscriber

  validates :subject, presence: true

  scope :subscriptions_for_activity, -> (activity) do
    where(
      subject: activity.subject,
      action: actions[activity.action_type.underscore]
    ).uniq
  end

  def self.active_subscribers_for_activity(activity)
    # User.includes(:activity_subscriptions).where(activity_subscriptions: {
    #   active: true,
    #   subject: activity.subject,
    #   action: actions[activity.action_type.underscore]
    # }).uniq
    User.joins(:activity_subscriptions).where(activity_subscriptions: {
      active: true,
      subject: activity.subject,
      action: ActivitySubscription.actions[activity.action_type.underscore]
    }).uniq.select('users.*, activity_subscriptions.reason AS subscription_reason')
  end
end
