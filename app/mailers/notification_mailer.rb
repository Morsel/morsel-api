class NotificationMailer < MandrillMailer::TemplateMailer
  def username_reserved_notification(user_id)
    user = User.find(user_id)
    email = Emails::UsernameReservedEmail.email(user)
    mandrill_mail email.mandrill_hash
  end
end
