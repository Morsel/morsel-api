class EmailWorker
  include Sidekiq::Worker

  def perform(user_id, email_type = nil)
    user = User.find(user_id)
    if email_type == 'forgot_password'
      user.send_reset_password_instructions
    elsif email_type == 'reserved_username' && !user.unsubscribed?
      email = Emails::UsernameReservedEmail.email(user)
      NotificationMailer.username_reserved_notification(user_id).deliver unless email.stop_sending?
    end
  end
end
