class CreateActivity
  include Service

  attribute :subject, Hash
  attribute :action, Hash
  attribute :creator_id
  attribute :notify_recipients, Boolean, default: false
  attribute :hidden, Boolean, default: false
  attribute :silent, Boolean, default: false

  def call
    activity = create_activity
    if notify_recipients?
      ActivitySubscription.active_subscribers_for_activity(activity).each do |activity_subscriber|
        reason = activity_subscriber.respond_to?(:subscription_reason) ? ActivitySubscription.reasons.keys[activity_subscriber.subscription_reason] : nil
        create_notification(activity, activity_subscriber.id, reason)
      end
    end
    activity
  end

  private

  def create_activity(hidden = hidden)
    Activity.create(
      creator_id: creator_id,
      action_id: safe_action[:id],
      action_type: safe_action[:type],
      subject_id: safe_subject[:id],
      subject_type: safe_subject[:type],
      hidden: hidden
    )
  end

  def notify_recipients?
    notify_recipients &&
    creator_id.present?
  end

  def create_notification(activity, recipient_id, reason = nil)
    CreateNotification.call(
      payload: activity,
      user_id: recipient_id,
      silent:  silent,
      reason:  reason
    ) unless recipient_id.to_i == creator_id.to_i
  end

  def safe_subject
    @safe_subject ||= subject ? subject.symbolize_keys : {}
  end

  def safe_action
    @safe_action ||= action ? action.symbolize_keys : {}
  end
end
