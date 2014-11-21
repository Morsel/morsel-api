class SubscribeToSubjectActivity
  include Service

  attribute :subject
  attribute :subscriber, User
  attribute :actions, Array
  attribute :reason, String
  attribute :active, Boolean, default: true

  validates :subject, presence: true
  validates :subscriber, presence: true
  validates :actions, presence: true
  validates :reason, presence: true

  def call
    create_activity_subscriptions_for_each_action
  end

  private

  def create_activity_subscriptions_for_each_action
    actions.map do |action|
      ActivitySubscription.create(
        subject: subject,
        subscriber: subscriber,
        action: ActivitySubscription.actions[action],
        reason: ActivitySubscription.reasons[reason],
        active: active
      )
    end
  end
end
