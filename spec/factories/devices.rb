# ## Schema Information
#
# Table name: `devices`
#
# ### Columns
#
# Name                         | Type               | Attributes
# ---------------------------- | ------------------ | ---------------------------
# **`id`**                     | `integer`          | `not null, primary key`
# **`user_id`**                | `integer`          |
# **`name`**                   | `string(255)`      |
# **`token`**                  | `string(255)`      |
# **`model`**                  | `string(255)`      |
# **`created_at`**             | `datetime`         |
# **`updated_at`**             | `datetime`         |
# **`deleted_at`**             | `datetime`         |
# **`notification_settings`**  | `hstore`           | `default({})`
#

FactoryGirl.define do
  factory :device do
    name { "#{Faker::Name.name}'s Device" }
    token { Faker::Lorem.characters(32) }
    model "iphone"

    association(:user)
  end
end
