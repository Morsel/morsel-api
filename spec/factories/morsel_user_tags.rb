# ## Schema Information
#
# Table name: `morsel_tagged_users`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`morsel_id`**   | `integer`          |
# **`user_id`**     | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

FactoryGirl.define do
  factory :morsel_user_tag do
    association(:morsel, factory: :morsel_with_creator)
    association(:user)
  end
end
