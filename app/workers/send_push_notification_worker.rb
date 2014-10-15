class SendPushNotificationWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    notification = Notification.find(options['notification_id'])
    SendPushNotification.call(notification: notification) if notification
  end
end
