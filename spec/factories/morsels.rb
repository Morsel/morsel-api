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
# **`draft`**               | `boolean`          | `default(FALSE), not null`
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :morsel_without_description_and_photo, class: Morsel do
    factory :morsel do
      description { Faker::Lorem.sentence(rand(5..100)) }
      photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
      draft false

      factory :morsel_draft, class: Morsel do
        draft true
      end

      factory :morsel_with_creator, class: Morsel do
        association(:creator, factory: :user)

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
end
