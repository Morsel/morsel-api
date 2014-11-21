class CreateNotification
  include Service

  attribute :payload
  attribute :user_id, String
  attribute :silent, Boolean, default: false
  attribute :reason, String

  def call
    Notification.create(
      payload: payload,
      message: notification_message,
      user_id: user_id,
      silent:  silent,
      reason:  reason
    )
  end

  private

  def notification_message
    ActivityPayloadDecorator.new(payload).message(user_id) if payload.is_a? Activity
  end
end
