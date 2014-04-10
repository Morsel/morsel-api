# ## Schema Information
#
# Table name: `items`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`description`**         | `text`             |
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`deleted_at`**          | `datetime`         |
# **`nonce`**               | `string(255)`      |
# **`photo_processing`**    | `boolean`          |
# **`morsel_id`**           | `integer`          |
# **`sort_order`**          | `integer`          |
#

FactoryGirl.define do
  factory :item do
    association(:morsel)
    description { Faker::Lorem.sentence(rand(5..100)) }
    photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))

    factory :item_with_creator, class: Item do
      association(:creator, factory: :user)
      factory :item_with_creator_and_morsel do
        association(:morsel, factory: :morsel_with_creator)
      end
      factory :item_with_likers do
        ignore do
          likes_count 3
        end

        after(:create) do |item, evaluator|
          create_list(:like, evaluator.likes_count, item: item)
        end
      end
      factory :item_with_creator_and_comments do
        ignore do
          comments_count 2
        end

        after(:create) do |item, evaluator|
          create_list(:comment, evaluator.comments_count, item: item)
        end
      end
    end
  end
end
