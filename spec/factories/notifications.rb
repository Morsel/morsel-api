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
    association(:payload, factory: :item_like_activity)
    association(:user)
    message 'Some notification message'
  end
end
