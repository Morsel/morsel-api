# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`liker_id`**       | `integer`          |
# **`likeable_id`**    | `integer`          |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`likeable_type`**  | `string(255)`      |
#

FactoryGirl.define do
  factory :like, class: Like do
    association(:liker, factory: :user)

    factory :item_like, class: Like do
      association(:likeable, factory: :item_with_creator)
    end

    factory :morsel_like, class: Like do
      association(:likeable, factory: :morsel_with_creator)
    end
  end
end
