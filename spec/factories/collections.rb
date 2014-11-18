# ## Schema Information
#
# Table name: `collections`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`title`**        | `string(255)`      |
# **`description`**  | `text`             |
# **`user_id`**      | `integer`          |
# **`place_id`**     | `integer`          |
# **`deleted_at`**   | `datetime`         |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`cached_slug`**  | `string(255)`      |
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection do
    title { Faker::Lorem.sentence(rand(2..4)).truncate(70) }
    description { Faker::Lorem.sentence(rand(5..100)) }
    association(:user)
    association(:place)

    factory :collection_with_morsels, traits: [:with_morsels]

    trait :with_morsels do
      ignore do
        morsels_count 3
      end

      after(:create) do |collection, evaluator|
        create_list(:morsel_with_items, evaluator.morsels_count, collections: [collection])
      end
    end
  end
end
