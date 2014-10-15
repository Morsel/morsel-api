class ApnsNotificationDecorator < SimpleDelegator
  def alert
    # Don't show a message for Likes
    message unless activity_payload? && payload.action_type == 'Like'
  end

  def sound
    # Only play a sound for Comments
    'default' if activity_payload? && payload.action_type == 'Comment'
  end

  private

  def activity_payload?
    payload.is_a? Activity
  end
end
