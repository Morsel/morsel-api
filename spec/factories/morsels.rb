# ## Schema Information
#
# Table name: `morsels`
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
# **`post_id`**             | `integer`          |
# **`sort_order`**          | `integer`          |
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :morsel do
    association(:post)
    description { Faker::Lorem.sentence(rand(5..100)) }
    photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))

    factory :morsel_with_creator, class: Morsel do
      association(:creator, factory: :user)
      factory :morsel_with_likers do
        ignore do
          likes_count 3
        end

        after(:create) do |morsel, evaluator|
          create_list(:like, evaluator.likes_count, morsel: morsel)
        end
      end
      factory :morsel_with_creator_and_comments do
        ignore do
          comments_count 2
        end

        after(:create) do |morsel, evaluator|
          create_list(:comment, evaluator.comments_count, morsel: morsel)
        end
      end
    end
  end
end
