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
# **`mrsl`**                | `hstore`           |
# **`place_id`**            | `integer`          |
# **`template_id`**         | `integer`          |
# **`likes_count`**         | `integer`          | `default(0), not null`
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
          twitter_mrsl: 'https://mrsl.co/twitter',
          clipboard: 'http://mrsl.co/clipboard',
          facebook_media: 'http://mrsl.co/facebook_media',
          twitter_media: 'http://mrsl.co/twitter_media',
          clipboard_media: 'http://mrsl.co/clipboard_media',
          pinterest_media: 'http://mrsl.co/pinterest_media',
          linkedin_media: 'http://mrsl.co/linkedin_media',
          googleplus_media: 'http://mrsl.co/googleplus_media'
        }
      end
    end

    factory :draft_morsel, class: Morsel do
      draft true
      published_at nil
    end

    factory :morsel_with_creator, class: Morsel do
      before(:build) do
        stub_foursquare_venue
      end
      association(:creator, factory: :user)
      association(:place)
      factory :morsel_with_creator_and_photo do
        photo Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
      end

      factory :morsel_with_items, class: Morsel do
        ignore do
          build_feed_item true
          featured_feed_item false
          items_count 3
        end

        after(:create) do |morsel, evaluator|
          create_list(:item, evaluator.items_count, morsel: morsel, creator: morsel.creator)
          morsel.primary_item_id = morsel.item_ids.last
          morsel.build_feed_item(subject_id: morsel.id, subject_type: 'Morsel', visible: true, user: morsel.creator, place: morsel.place, featured: evaluator.featured_feed_item) if evaluator.build_feed_item
          morsel.published_at = Time.at(morsel.id) + 1000 if morsel.published_at
          morsel.updated_at = Time.at(morsel.id) + 1000
          morsel.save
        end

        factory :draft_morsel_with_items, class: Morsel do
          draft true
          published_at nil
        end
      end
    end
  end
end
