class ActivityWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    creator = User.find(options['creator']['id'])
    activity = Activity.create(
      creator_id: options['creator']['id'],
      action_id: options['action']['id'],
      action_type: options['action']['type'],
      subject_id: options['subject']['id'],
      subject_type: options['subject']['type'],
      recipient_id: options['recipient']['id']
    )

    notify_recipient = options['notify_recipient'] || false

    if notify_recipient && options['recipient']['id'].present? && options['recipient']['id'] != options['creator']['id']
      if options['action']['type'] == 'Comment'
        past_tense_action = 'commented on'
      elsif options['action']['type'] == 'Like'
        past_tense_action = 'liked'
      elsif options['action']['type'] == 'Follow'
        past_tense_action = 'followed'
      else
        raise 'InvalidAction'
      end

      if options['subject']['type'] == 'User'
        subject_message = activity.subject.full_name
      elsif options['subject']['type'] == 'Item'
        subject_message = activity.subject.morsel_title_with_description
      else
        raise 'InvalidSubject'
      end

      notification_message = "#{creator.full_name} (#{creator.username}) #{past_tense_action} #{subject_message}"
      Notification.create(
        payload: activity,
        message: notification_message.truncate(100, separator: ' ', omission: '... '),
        user_id: options['recipient']['id']
      )
    end
  end
end
