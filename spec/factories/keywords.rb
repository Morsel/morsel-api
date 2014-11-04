# ## Schema Information
#
# Table name: `keywords`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`type`**             | `string(255)`      |
# **`name`**             | `string(255)`      |
# **`deleted_at`**       | `datetime`         |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`followers_count`**  | `integer`          | `default(0), not null`
#

FactoryGirl.define do
  factory :cuisine do
    name { "cuisine_#{Faker::Lorem.characters(10)}" }
    type 'Cuisine'
  end

  factory :food_and_drink do
    name { "food_and_drink_#{Faker::Lorem.characters(10)}" }
    type 'FoodAndDrink'
  end

  factory :specialty do
    name { "specialty_#{Faker::Lorem.characters(10)}" }
    type 'Specialty'
  end
end
