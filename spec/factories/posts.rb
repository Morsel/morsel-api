# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`title`**         | `string(255)`      |
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
# **`creator_id`**    | `integer`          |
# **`cached_slug`**   | `string(255)`      |
# **`deleted_at`**    | `datetime`         |
# **`draft`**         | `boolean`          | `default(FALSE), not null`
# **`published_at`**  | `datetime`         |
#

FactoryGirl.define do
  factory :post do
    title { Faker::Lorem.sentence(rand(2..4)).truncate(50) }
    draft false

    factory :post_with_creator, class: Post do
      association(:creator, factory: :user)
    end

    factory :post_with_morsels, class: Post do
      ignore do
        morsels_count 3
      end

      after(:create) do |post, evaluator|
        create_list(:morsel, evaluator.morsels_count, posts: [post], creator: post.creator)
      end

      factory :post_with_morsels_and_creator, class: Post do
        association(:creator, factory: :user)

        factory :draft_post_with_morsels_and_creator, class: Post do
          draft true
        end
      end
    end
  end
end
