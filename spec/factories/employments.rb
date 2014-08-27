# ## Schema Information
#
# Table name: `employments`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`place_id`**    | `integer`          |
# **`user_id`**     | `integer`          |
# **`title`**       | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

FactoryGirl.define do
  factory :employment do
    association(:place)
    association(:user)
    title { Faker::Name.title }
  end
end
