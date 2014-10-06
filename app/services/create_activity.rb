class CreateActivity
  include Service

  attribute :subject, Hash
  attribute :action, Hash
  attribute :creator_id, String
  attribute :recipient_id, String
  attribute :notify_recipient, Boolean, default: false
  attribute :hidden, Boolean, default: false

  def call
    create_activity
    send_notification if notify_recipient?
  end

  private

  def activity
    @activity ||= Activity.create(
      creator_id: creator_id,
      action_id: safe_action[:id],
      action_type: safe_action[:type],
      subject_id: safe_subject[:id],
      subject_type: safe_subject[:type],
      recipient_id: recipient_id,
      hidden: hidden?
    )
  end
  alias_method :create_activity, :activity

  def hidden?
    hidden
  end

  def notify_recipient?
    notify_recipient &&
    creator_id.present? &&
    recipient_id.present? &&
    creator_id != recipient_id
  end

  def send_notification
    CreateNotification.call(
      payload: activity,
      user_id: recipient_id
    )
  end

  def safe_subject
    @safe_subject ||= subject ? subject.symbolize_keys : {}
  end

  def safe_action
    @safe_action ||= action ? action.symbolize_keys : {}
  end
end
