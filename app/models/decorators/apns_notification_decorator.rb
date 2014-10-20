class ApnsNotificationDecorator < SimpleDelegator
  def alert
    # Don't show a message for Likes
    message unless activity_payload? && payload.action_type == 'Like'
  end

  def custom_payload
    { route: activity_route }
  end

  def sound
    # Only play a sound for Comments
    'default' if activity_payload? && payload.action_type == 'Comment'
  end

  def activity_type
    "#{payload.subject_type.downcase}_#{payload.action_type.downcase}" if activity_payload?
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
    end
  end
end
