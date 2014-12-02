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
# **`promoted`**         | `boolean`          | `default(FALSE)`
# **`tags_count`**       | `integer`          | `default(0), not null`
#

FactoryGirl.define do
  factory :cuisine, class: Cuisine do
    name { "cuisine_#{Faker::Lorem.characters(10)}" }
  end

  factory :food_and_drink, class: FoodAndDrink do
    name { "food_and_drink_#{Faker::Lorem.characters(10)}" }
  end

  factory :hashtag, class: Hashtag do
    name { "hashtag_#{Faker::Lorem.characters(10)}" }
  end

  factory :specialty, class: Specialty do
    name { "specialty_#{Faker::Lorem.characters(10)}" }
  end
end
