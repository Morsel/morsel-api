# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`title`**               | `string(255)`      |
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`cached_slug`**         | `string(255)`      |
# **`deleted_at`**          | `datetime`         |
# **`draft`**               | `boolean`          | `default(TRUE), not null`
# **`published_at`**        | `datetime`         |
# **`primary_item_id`**     | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
#

FactoryGirl.define do
  factory :morsel do
    title { Faker::Lorem.sentence(rand(2..4)).truncate(50) }
    draft false
    ignore do
      include_mrsl true
    end

    after(:build) do |morsel, evaluator|
      if evaluator.include_mrsl
        morsel.mrsl = {
          facebook_mrsl: 'https://mrsl.co/facebook',
          twitter_mrsl: 'https://mrsl.co/twitter'
        }
      end
    end

    factory :morsel_with_creator, class: Morsel do
      association(:creator, factory: :user)
      factory :morsel_with_creator_and_photo do
        photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
      end

      factory :morsel_with_items, class: Morsel do
        ignore do
          build_feed_item true
          items_count 3
        end

        after(:create) do |morsel, evaluator|
          create_list(:item, evaluator.items_count, morsel: morsel, creator: morsel.creator)
          morsel.primary_item_id = morsel.item_ids.last
          morsel.build_feed_item(subject_id: morsel.id, subject_type: 'Morsel', visible: true) if evaluator.build_feed_item
          morsel.save
        end

        factory :draft_morsel_with_items, class: Morsel do
          draft true
        end
      end
    end
  end
end
