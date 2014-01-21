# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`title`**        | `string(255)`      |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`creator_id`**   | `integer`          |
# **`cached_slug`**  | `string(255)`      |
#

FactoryGirl.define do
  factory :post do
    title { Faker::Lorem.sentence(rand(2..5)) }

    factory :post_with_morsels, class: Post do
      ignore do
        morsels_count 3
      end

      after(:create) do |post, evaluator|
        create_list(:morsel, evaluator.morsels_count, posts: [post], creator: post.creator)
      end

      factory :post_with_morsels_and_creator, class: Post do
        association(:creator, factory: :user)
      end
    end
  end
end
