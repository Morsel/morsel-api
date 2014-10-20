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

  factory :item_comment_activity, class: Activity do
    association(:creator, factory: :user)
    association(:action, factory: :item_comment)
    association(:subject, factory: :item_with_creator)
  end

  factory :morsel_like_activity, class: Activity do
    association(:creator, factory: :user)
    association(:action, factory: :morsel_like)
    association(:subject, factory: :morsel_with_creator)
  end

  factory :morsel_morsel_user_tag_activity, class: Activity do
    association(:creator, factory: :user)
    association(:action, factory: :morsel_user_tag)
    association(:subject, factory: :morsel_with_creator)
  end

  factory :user_follow_activity, class: Activity do
    association(:creator, factory: :user)
    association(:action, factory: :user_follow)
    association(:subject, factory: :user)
  end

  factory :hidden_activity, class: Activity do
    hidden true
  end
end
