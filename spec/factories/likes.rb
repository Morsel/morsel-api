# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`user_id`**     | `integer`          |
# **`item_id`**     | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

FactoryGirl.define do
  factory :like do
    association(:user)
    association(:item, factory: :item_with_creator)
  end
end
