class CreateZendeskTicket
  include Service

  attribute :subject, String
  attribute :description, String
  attribute :tags, Array

  validates :subject, presence: true
  validate :token_set?

  def token_set?
    errors.add(:token, 'is not set') if Settings.zendesk.token.nil?
  end

  def call
    create_ticket
  end

  private

  def zendesk_client
    @zendesk_client ||= ZendeskAPI::Client.new do |config|
      config.url = Settings.zendesk.url
      config.username = Settings.zendesk.username
      config.token = Settings.zendesk.token
    end
  end

  def create_ticket
    ZendeskAPI::Ticket.create(zendesk_client,
      subject: subject,
      description: description,
      submitter_id: zendesk_client.current_user.id,
      priority: 'low',
      type: 'incident',
      tags: tags
    )
  end
end
