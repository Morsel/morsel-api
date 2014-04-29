# ## Schema Information
#
# Table name: `keywords`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`type`**        | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

FactoryGirl.define do
  factory :keyword do
    name { "keyword_#{Faker::Lorem.characters(10)}" }
  end

  factory :cuisine do
    name { "cuisine_#{Faker::Lorem.characters(10)}" }
    type 'Cuisine'
  end

  factory :specialty do
    name { "specialty_#{Faker::Lorem.characters(10)}" }
    type 'Specialty'
  end
end
