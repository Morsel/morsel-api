# ## Schema Information
#
# Table name: `subscribers`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`email`**       | `string(255)`      |
# **`url`**         | `string(255)`      |
# **`source_url`**  | `string(255)`      |
# **`role`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`user_id`**     | `integer`          |
#

FactoryGirl.define do
  factory :subscriber do
    email { Faker::Internet.email }
    url { Faker::Internet.domain_name }
    source_url { Faker::Internet.domain_name }
    role 'chef'
    user_id 1
  end
end
