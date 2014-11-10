class CreateActivity
  include Service

  attribute :subject, Hash
  attribute :action, Hash
  attribute :creator_id
  attribute :primary_recipient_id
  attribute :additional_recipient_ids, Array, default: []
  attribute :notify_recipients, Boolean, default: false
  attribute :hidden, Boolean, default: false
  attribute :silent, Boolean, default: false

  def call
    primary_activity = create_activity(primary_recipient_id)
    create_notification(primary_activity) if notify_recipients?

    # Create any additional activities and notifications for additional recipients
    if !additional_recipient_ids.empty?
      additional_recipient_ids.each do |recipient_id|
        activity = create_activity(recipient_id, true)
        create_notification(activity) if notify_recipients?
      end
    end
  end

  private

  def create_activity(recipient_id, hidden = hidden)
    Activity.create(
      creator_id: creator_id,
      action_id: safe_action[:id],
      action_type: safe_action[:type],
      subject_id: safe_subject[:id],
      subject_type: safe_subject[:type],
      recipient_id: recipient_id,
      hidden: hidden
    )
  end

  def notify_recipients?
    notify_recipients &&
    creator_id.present?
  end

  def create_notification(activity)
    CreateNotification.call(
      payload: activity,
      user_id: activity.recipient_id,
      silent:  silent
    ) if activity.recipient_id.to_i != creator_id.to_i
  end

  def safe_subject
    @safe_subject ||= subject ? subject.symbolize_keys : {}
  end

  def safe_action
    @safe_action ||= action ? action.symbolize_keys : {}
  end
end
