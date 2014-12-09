class SendPushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :push_notifications

  def perform(options = nil)
    return if options.nil?

    notification = Notification.find_by(id: options['notification_id'])
    if notification
      SendPushNotification.call(notification: notification, user: notification.user)
    elsif options['notification_id']
      Rollbar.info "Couldn't find Notification ##{options['notification_id']} push, ignoring."
    else
      user = User.find options['user_id']
      SendPushNotification.call(user: user) if user
    end
  end
end
