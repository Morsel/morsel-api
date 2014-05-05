class EmailUserDecorator < SimpleDelegator
  def send_forgot_password_email
    EmailWorker.perform_async(id, 'forgot_password')
  end

  def send_reserved_username_email
    EmailWorker.perform_async(id, 'reserved_username') unless unsubscribed?
  end
end
