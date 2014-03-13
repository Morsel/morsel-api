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

    if notify_recipient && recipient_id.present?
      if action_type == 'Comment'
        past_tense_action = 'commented on'
      elsif action_type == 'Like'
        past_tense_action = 'liked'
      else
        raise 'InvalidAction'
      end

      message = "#{creator.full_name} (#{creator.username}) #{past_tense_action} #{activity.subject.first_post_title_with_description}"
      Notification.create(
        payload: activity,
        message: message.truncate(100, separator: ' ', omission: '... '),
        user_id: recipient_id
      )
    end
  end
end
