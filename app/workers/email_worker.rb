class EmailWorker
  include Sidekiq::Worker

  def perform(user_id, email_type = nil)
    email = Emails::UsernameReservedEmail.email(User.find(user_id))
    NotificationMailer.username_reserved_notification(user_id).deliver unless email.stop_sending?
  end
end
