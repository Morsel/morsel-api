class EmailWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    user = User.find(options['user']['id'])
    if options['email']['type'] == 'forgot_password'
      user.send_reset_password_instructions
    elsif options['email']['type'] == 'reserved_username' && !user.unsubscribed?
      email = Emails::UsernameReservedEmail.email(user)
      NotificationMailer.username_reserved_notification(options['user']['id']).deliver unless email.stop_sending?
    end
  end
end
