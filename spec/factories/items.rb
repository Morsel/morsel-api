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
# **`template_order`**      | `integer`          |
#

FactoryGirl.define do
  factory :item do
    association(:morsel)
    description { Faker::Lorem.sentence(rand(5..100)) }

    factory :item_with_creator, class: Item do
      photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
      association(:creator, factory: :user)
      factory :item_with_creator_and_morsel do
        association(:morsel, factory: :morsel_with_creator)
      end
      factory :item_with_likers do
        ignore do
          likes_count 3
        end

        after(:create) do |item, evaluator|
          create_list(:item_like, evaluator.likes_count, likeable: item)
        end
      end
      factory :item_with_creator_and_comments do
        ignore do
          comments_count 2
        end

        after(:create) do |item, evaluator|
          create_list(:item_comment, evaluator.comments_count, commentable: item)
        end
      end
    end
  end
end
