class SendPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :push_notifications

  def perform(options = nil)
    return if options.nil?

    notification = Notification.find_by(id: options['notification_id'])
    if notification
      SendPushNotification.call(notification: notification)
    else
      Rollbar.report_message "Couldn't find Notification ##{options['notification_id']} push, ignoring.", 'info'
    end
  end
end
