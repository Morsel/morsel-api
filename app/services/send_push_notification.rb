class SendPushNotification
  include Service

  attribute :notification, Notification

  validates :notification, presence: true
  validate :valid_notification?

  def valid_notification?
    return errors.add(:notification, 'not found') unless notification
    errors.add(:payload, 'not found') unless notification.payload
    errors.add(:user, 'not found') unless notification.user
  end

  def call
    return false if notification.read? || notification.sent? || devices.count == 0
    send_push_notifications
    push_notifications
  end

  private

  def user
    @user ||= notification.user
  end

  def certificate
    @certificate ||= if Rails.env.staging? || Rails.env.production?
      StringIO.new ENV['APNS_CERT'] # Settingslogic doesn't correctly handle this, so use ENV directly.
    else
      ENV['APNS_CERT_PATH']
    end
  end

  def decorated_notification
    @decorated_notification ||= ApnsNotificationDecorator.new(notification)
  end

  def devices
    user.devices
  end

  def unread_badge_count
    Notification.includes(:user).unread_for_user_id(user.id).count
  end

  def expiry
    1.week.since.to_time
  end

  def get_feedback
    feedback ||= Grocer.feedback(
      certificate: certificate
    )

    feedback.map do |attempt|
      errors.add :device, "#{attempt.device_token} failed at #{attempt.timestamp}"
    end
  end

  def notification_allowed_for_device(device)
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(device.notification_settings["notify_#{decorated_notification.activity_type}"])
  end

  def pusher
    @pusher ||= Grocer.pusher(
      certificate: certificate
    )
  end

  def push_notifications
    @push_notifications ||= devices.map do |device|
      Grocer::Notification.new(
        device_token:  device.token,
        alert:         decorated_notification.alert,
        badge:         unread_badge_count,
        sound:         decorated_notification.sound,
        expiry:        expiry,
        identifier:    notification.id,
        custom:        decorated_notification.custom_payload
      ) if notification_allowed_for_device device
    end.compact
  end

  def send_push_notifications
    push_notifications.each do |push_notification|
      pusher.push(push_notification)
    end
    notification.mark_sent!
    get_feedback # Since a notification is marked as sent already this is mainly used to log what errors are happening
  end
end
