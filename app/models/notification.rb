# ## Schema Information
#
# Table name: `notifications`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `integer`          | `not null, primary key`
# **`payload_id`**      | `integer`          |
# **`payload_type`**    | `string(255)`      |
# **`message`**         | `text`             |
# **`user_id`**         | `integer`          |
# **`marked_read_at`**  | `datetime`         |
# **`deleted_at`**      | `datetime`         |
# **`created_at`**      | `datetime`         |
# **`updated_at`**      | `datetime`         |
# **`sent_at`**         | `datetime`         |
# **`reason`**          | `string(255)`      |
#

class Notification < ActiveRecord::Base
  include Authority::Abilities,
          TimelinePaginateable

  acts_as_paranoid
  belongs_to :payload, polymorphic: true
  belongs_to :user
  has_many :remote_notifications

  attr_accessor :silent

  after_commit :queue_push_notification, on: :create

  scope :unread, -> { where(marked_read_at: nil) }
  scope :unread_for_user_id, -> (user_id) { unread.where(user_id: user_id) }

  self.authorizer_name = 'NotificationAuthorizer'

  def read?
    marked_read_at.present?
  end

  def sent?
    sent_at.present?
  end

  def mark_read!
    update(marked_read_at: DateTime.now) unless marked_read_at
  end

  def mark_sent!
    update(sent_at: DateTime.now) unless sent_at
  end

  def remote_notification_allowed_for_device?(device)
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(device.notification_settings["notify_#{activity_subject_action}"])
  end

  def activity_subject_action
    "#{payload.subject_type.underscore}_#{payload.action_type.underscore}" if payload.is_a? Activity
  end

  private

  def queue_push_notification
    SendPushNotificationWorker.perform_in(30.seconds, notification_id: id) unless silent
  end
end
