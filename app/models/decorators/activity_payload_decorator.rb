class ActivityPayloadDecorator < SimpleDelegator
  def message(user = nil)
    "#{creator.full_name} (#{creator.username}) #{past_tense_action} #{subject_message(user)}"
  end

  private

  def past_tense_action
    case action_type
    when 'Comment'
      'commented on'
    when 'Like'
      'liked'
    when 'Follow'
      'followed'
    when 'MorselUserTag'
      'tagged you in'
    else
      raise 'Invalid Activity Action'
    end
  end

  def subject_message(user)
    case subject_type
    when 'User'
      user == subject ? 'you' : subject.full_name
    when 'Item'
      subject.morsel_title_with_description
    when 'Morsel'
      subject.title
    when 'Place'
      subject.name
    else
      raise 'Invalid Activity Subject'
    end
  end
end
