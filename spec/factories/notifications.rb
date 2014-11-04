# ## Schema Information
#
# Table name: `notifications`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `integer`          | `not null, primary key`
# **`payload_id`**      | `integer`          |
# **`payload_type`**    | `string(255)`      |
# **`message`**         | `string(255)`      |
# **`user_id`**         | `integer`          |
# **`marked_read_at`**  | `datetime`         |
# **`deleted_at`**      | `datetime`         |
# **`created_at`**      | `datetime`         |
# **`updated_at`**      | `datetime`         |
# **`sent_at`**         | `datetime`         |
#

FactoryGirl.define do
  factory :activity_notification, class: Notification do
    association(:payload)
    association(:user)
    message 'Some notification message'

    factory :item_comment_activity_notification do
      association(:payload, factory: :item_comment_activity)
    end

    factory :morsel_like_activity_notification do
      association(:payload, factory: :morsel_like_activity)
    end

    factory :morsel_morsel_user_tag_activity_notification do
      association(:payload, factory: :morsel_morsel_user_tag_activity)
    end

    factory :user_follow_activity_notification do
      association(:payload, factory: :user_follow_activity)
    end
  end
end
