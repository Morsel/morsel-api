class CreateUserEvent
  include Service

  attribute :name, String
  attribute :user_id, String
  attribute :client, Hash
  attribute :__utmz, String
  attribute :properties, Hash

  validates :name, presence: true

  def call
    create_event
  end

  private

  def create_event
    @user_event ||= UserEvent.create(
      user_id: user_id,
      name: name,
      client_device: safe_client_device,
      client_version: safe_client_version,
      __utmz: __utmz,
      properties: properties
    )
  end

  def safe_client_device
    client['device'] if client.present?
  end

  def safe_client_version
    client['version'] if client.present?
  end
end
