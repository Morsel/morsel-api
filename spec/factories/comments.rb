# ## Schema Information
#
# Table name: `comments`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `integer`          | `not null, primary key`
# **`commenter_id`**      | `integer`          |
# **`commentable_id`**    | `integer`          |
# **`description`**       | `text`             |
# **`deleted_at`**        | `datetime`         |
# **`created_at`**        | `datetime`         |
# **`updated_at`**        | `datetime`         |
# **`commentable_type`**  | `string(255)`      |
#

FactoryGirl.define do
  factory :comment, class: Comment do
    description { Faker::Lorem.sentence(rand(5..100)) }
    association(:commenter, factory: :user)
    factory :item_comment, class: Comment do
      association(:commentable, factory: :item_with_creator)
    end
  end
end
