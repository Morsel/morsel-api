# ## Schema Information
#
# Table name: `tags`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`tagger_id`**      | `integer`          |
# **`keyword_id`**     | `integer`          |
# **`taggable_id`**    | `integer`          |
# **`taggable_type`**  | `string(255)`      |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
#

FactoryGirl.define do
  factory :user_tag, class: Tag do
    association(:tagger, factory: :user)
    association(:taggable, factory: :user)

    factory :user_cuisine_tag, class: Tag do
      association(:keyword, factory: :cuisine)
    end

    factory :user_specialty_tag, class: Tag do
      association(:keyword, factory: :specialty)
    end
  end
end
