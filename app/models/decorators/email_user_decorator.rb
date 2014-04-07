class EmailUserDecorator < SimpleDelegator
  def send_reserved_username_email
    EmailWorker.perform_async(id) unless unsubscribed?
  end
end
