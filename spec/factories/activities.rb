# ## Schema Information
#
# Table name: `activities`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`subject_id`**       | `integer`          |
# **`subject_type`**     | `string(255)`      |
# **`action_id`**        | `integer`          |
# **`action_type`**      | `string(255)`      |
# **`creator_id`**       | `integer`          |
# **`recipient_id`**     | `integer`          |
# **`notification_id`**  | `integer`          |
# **`deleted_at`**       | `datetime`         |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`hidden`**           | `boolean`          | `default(FALSE)`
#

FactoryGirl.define do
  factory :item_like_activity, class: Activity do
    association(:creator, factory: :user)
    association(:action, factory: :item_like)
    association(:subject, factory: :item_with_creator_and_morsel)
  end

  factory :hidden_activity, class: Activity do
    hidden true
  end
end
