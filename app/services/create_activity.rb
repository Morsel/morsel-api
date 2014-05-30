class CreateActivity
  include Service

  attribute :subject, Hash
  attribute :action, Hash
  attribute :creator_id, String
  attribute :recipient_id, String

  def call
    create_activity
    send_notification if notify_recipient?
  end

  private

  def activity
    @activity ||= Activity.create(
      creator_id: creator_id,
      action_id: action['id'],
      action_type: action['type'],
      subject_id: subject['id'],
      subject_type: subject['type'],
      recipient_id: recipient_id
    )
  end
  alias_method :create_activity, :activity

  def creator
    @creator ||= User.find creator_id
  end

  concerning :Notifications do
    included do
      attribute :notify_recipient, Boolean, default: false
    end

    def notification_message
      "#{creator.full_name} (#{creator.username}) #{past_tense_action} #{subject_message}"
    end

    def notify_recipient?
      notify_recipient &&
      creator_id.present? &&
      recipient_id.present? &&
      creator_id != recipient_id
    end

    def past_tense_action
      case action['type']
      when 'Comment'
        'commented on'
      when 'Like'
        'liked'
      when 'Follow'
        'followed'
      else
        raise 'Invalid Activity Action'
      end
    end

    def send_notification
      Notification.create(
        payload: activity,
        message: notification_message.truncate(100, separator: ' ', omission: '... '),
        user_id: recipient_id
      )
    end

    def subject_message
      case subject['type']
      when 'User'
        activity.subject.full_name
      when 'Item'
        activity.subject.morsel_title_with_description
      when 'Place'
        activity.subject.name
      else
        raise 'Invalid Activity Subject'
      end
    end
  end
end
