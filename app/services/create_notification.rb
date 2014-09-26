class CreateNotification
  include Service

  attribute :payload
  attribute :user_id, String

  def call
    Notification.create(
      payload: payload,
      message: notification_message.truncate(Settings.morsel.notification_length, separator: ' ', omission: '... '),
      user_id: user_id
    )
  end

  private

  def notification_message
    ActivityPayloadDecorator.new(payload).message if payload.is_a? Activity
  end
end
