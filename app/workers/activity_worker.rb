class ActivityWorker
  include Sidekiq::Worker

  def perform(subject_id, subject_type, action_id, action_type, creator_id, recipient_id, notify_recipient = false)
    creator = User.find(creator_id)
    activity = Activity.create(
      creator_id: creator_id,
      action_id: action_id,
      action_type: action_type,
      subject_id: subject_id,
      subject_type: subject_type,
      recipient_id: recipient_id
    )

    if notify_recipient && recipient_id.present? && recipient_id != creator_id
      if action_type == 'Comment'
        past_tense_action = 'commented on'
      elsif action_type == 'Like'
        past_tense_action = 'liked'
      elsif action_type == 'Follow'
        past_tense_action = 'followed'
      else
        raise 'InvalidAction'
      end

      if subject_type == 'User'
        subject_message = activity.subject.full_name
      elsif subject_type == 'Item'
        subject_message = activity.subject.morsel_title_with_description
      else
        raise 'InvalidSubject'
      end

      notification_message = "#{creator.full_name} (#{creator.username}) #{past_tense_action} #{subject_message}"
      Notification.create(
        payload: activity,
        message: notification_message.truncate(100, separator: ' ', omission: '... '),
        user_id: recipient_id
      )
    end
  end
end
