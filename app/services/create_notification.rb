class CreateNotification
  include Service

  attribute :payload
  attribute :user_id, String
  attribute :silent, Boolean, default: false

  def call
    Notification.create(
      payload: payload,
      message: notification_message,
      user_id: user_id,
      silent:  silent
    )
  end

  private

  def notification_message
    ActivityPayloadDecorator.new(payload).message(user) if payload.is_a? Activity
  end
end
