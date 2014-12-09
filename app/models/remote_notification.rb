# ## Schema Information
#
# Table name: `remote_notifications`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`device_id`**        | `integer`          |
# **`notification_id`**  | `integer`          |
# **`user_id`**          | `integer`          |
# **`activity_type`**    | `string(255)`      |
# **`reason`**           | `string(255)`      |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
#

class RemoteNotification < ActiveRecord::Base
  belongs_to :device
  belongs_to :notification
  belongs_to :user

  before_create :default_values

  def grocer_notification(options = {})
    decorated_notification = ApnsNotificationDecorator.new(notification)
    Grocer::Notification.new({
      device_token:  device.token,
      alert:         decorated_notification.alert,
      badge:         nil,
      sound:         decorated_notification.sound,
      expiry:        1.week.since.to_time,
      identifier:    notification.id,
      custom:        decorated_notification.custom_payload
    }.merge(options))
  end

  private

  def default_values
    self.activity_type = notification.activity_subject_action
    self.reason = notification.reason
    self.user_id = notification.user_id
  end
end
