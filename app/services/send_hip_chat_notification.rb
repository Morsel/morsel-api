class SendHipChatNotification
  include Service

  attribute :message, String

  validates :message, presence: true
  validate :auth_token_set?

  def auth_token_set?
    errors.add(:auth_token, 'is not set') unless Settings.hipchat.auth_token
  end

  def call
    hipchat_client[default_room].send('API', message, notify: true, color: :green, message_format: :text)
  end

  private

  def default_room
    @default_room ||= Settings.hipchat.default_room
  end

  def hipchat_client
    @hipchat_client ||= HipChat::Client.new(Settings.hipchat.auth_token, api_version: 'v2')
  end
end
