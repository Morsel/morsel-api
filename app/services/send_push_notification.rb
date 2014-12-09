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
    remote_notifications
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

  def devices
    user.devices
  end

  def unread_badge_count
    @unread_badge_count ||= Notification.includes(:user).unread_for_user_id(user.id).count
  end

  def gateway
    Rails.env.development? ? 'gateway.sandbox.push.apple.com' : 'gateway.push.apple.com'
  end

  def get_feedback
    feedback ||= Grocer.feedback(
      certificate: certificate
    )

    feedback.map do |attempt|
      errors.add :device, "#{attempt.device_token} failed at #{attempt.timestamp}"
    end
  end

  def pusher
    @pusher ||= Grocer.pusher(
      certificate: certificate,
      gateway: gateway
    )
  end

  def remote_notifications
    @remote_notifications ||= devices.map do |device|
      if notification.remote_notification_allowed_for_device? device
        device.remote_notifications.create(
          notification_id: notification.id
        )
      end
    end.compact
  end

  def send_push_notifications
    remote_notifications.each do |remote_notification|
      pusher.push(remote_notification.grocer_notification(badge: unread_badge_count))
    end
    notification.mark_sent!
    get_feedback # Since a notification is marked as sent already this is mainly used to log what errors are happening
  end
end
