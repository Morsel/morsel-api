module ActivitySubscribeable
  extend ActiveSupport::Concern

  included do
    has_many :activity_subscribers, -> { uniq }, through: :activity_subscriptions, source: :subscriber, class_name: 'User'
    has_many :activity_subscriptions, as: :subject, dependent: :destroy

    after_commit :create_subscription_for_creator, on: :create
    after_destroy :remove_subscription_for_creator

    def self.activity_subscription_actions; raise 'NotImplementedError - activity_subscription_actions is not implemented for this ActivitySubscribeable' end
  end

  def add_subscriber(subscriber, actions, reason, active=true)
    SubscribeToSubjectActivityWorker.perform_async(
      subject_id: id,
      subject_type: self.class.to_s,
      subscriber_id: subscriber.id,
      active: active,
      reason: reason,
      actions: actions
    )
  end

  def remove_subscriber(subscriber, actions, reason)
    UnsubscribeFromSubjectActivityWorker.perform_async(
      subject_id: id,
      subject_type: self.class.to_s,
      subscriber_id: subscriber.id,
      reason: reason,
      actions: actions
    )
  end

  private

  def create_subscription_for_creator
    add_subscriber(creator, self.class.activity_subscription_actions, 'created')
  end

  def remove_subscription_for_creator
    remove_subscriber(creator, self.class.activity_subscription_actions, 'created')
  end
end
