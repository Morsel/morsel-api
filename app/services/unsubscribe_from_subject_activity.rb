class UnsubscribeFromSubjectActivity
  include Service

  attribute :subject
  attribute :subscriber, User
  attribute :actions, Array
  attribute :reason, String

  validates :subject, presence: true
  validates :subscriber, presence: true
  validates :actions, presence: true
  validates :reason, presence: true

  def call
    destroy_activity_subscriptions_for_each_action
  end

  private

  def destroy_activity_subscriptions_for_each_action
    actions.map do |action|
      activity_subscription = ActivitySubscription.find_by(
        subject: subject,
        subscriber: subscriber,
        action: ActivitySubscription.actions[action],
        reason: ActivitySubscription.reasons[reason]
      )

      if activity_subscription.present?
        activity_subscription.destroy
      else
        false
      end
    end
  end
end
