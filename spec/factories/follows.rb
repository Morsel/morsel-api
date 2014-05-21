# ## Schema Information
#
# Table name: `follows`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`follower_id`**      | `integer`          |
# **`followable_id`**    | `integer`          |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`followable_type`**  | `string(255)`      |
# **`deleted_at`**       | `datetime`         |
#

FactoryGirl.define do
  factory :follow, class: Follow do
    association(:follower, factory: :user)

    factory :keyword_follow, class: Follow do
      association(:followable, factory: :cuisine)
    end

    factory :user_follow, class: Follow do
      association(:followable, factory: :user)
    end
  end
end
