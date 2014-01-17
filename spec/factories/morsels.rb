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
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :morsel_without_description_and_photo, class: Morsel do
    factory :morsel do
      description { Faker::Lorem.sentence(rand(5..100)) }
      photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))

      factory :morsel_with_creator, class: Morsel do
        association(:creator, factory: :user)
      end
    end
  end
end
