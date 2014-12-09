class ApnsNotificationDecorator < SimpleDelegator
  def alert
    # Don't show a message for Likes
    truncated_message unless activity_payload? && payload.action_type == 'Like'
  end

  def custom_payload
    {
      route: activity_route,
      reason: reason
    }
  end

  def sound
    # Only play a sound for Comments or Morsel User Tags
    'default' if activity_payload? && (payload.action_type == 'Comment' || payload.action_type == 'MorselUserTag')
  end

  private

  def activity_payload?
    payload.is_a? Activity
  end

  def activity_route
    "#{activity_subject_route}/#{activity_action_route}" if activity_payload?
  end

  def activity_subject_route
    if payload.subject_type == 'Item'
      "morsels/#{payload.subject.morsel_id}/items/#{payload.subject_id}"
    elsif payload.subject_type == 'Morsel'
      "morsels/#{payload.subject_id}"
    elsif payload.subject_type == 'User'
      "users/#{payload.subject_id}"
    end
  end

  def activity_action_route
    if payload.action_type == 'Comment'
      'comments'
    elsif payload.action_type == 'Follow'
      'followers'
    elsif payload.action_type == 'Like'
      'likers'
    elsif payload.action_type == 'MorselUserTag'
      'user_tags'
    end
  end

  def truncated_message
    message.truncate(Settings.morsel.notification_length, separator: ' ', omission: '... ')
  end
end
