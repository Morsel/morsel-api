# ## Schema Information
#
# Table name: `remote_notifications`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`device_id`**        | `integer`          |
# **`notification_id`**  | `integer`          |
# **`user_id`**          | `integer`          |
# **`activity_type`**    | `string(255)`      |
# **`reason`**           | `string(255)`      |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
#

FactoryGirl.define do
  factory :remote_notification do
    association(:device)
    association(:user)

    factory :item_comment_remote_notification do
      association(:notification, factory: :item_comment_activity_notification)
    end
  end
end
