# ## Schema Information
#
# Table name: `feed_items`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`subject_id`**    | `integer`          |
# **`subject_type`**  | `string(255)`      |
# **`deleted_at`**    | `datetime`         |
# **`visible`**       | `boolean`          | `default(FALSE)`
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
# **`user_id`**       | `integer`          |
# **`featured`**      | `boolean`          | `default(FALSE)`
# **`place_id`**      | `integer`          |
#

FactoryGirl.define do
  factory :morsel_feed_item, class: FeedItem do
    association(:subject, factory: :morsel)
    association(:place, factory: :place)
    association(:user, factory: :user)
    factory :visible_morsel_feed_item, class: FeedItem do
      visible true
    end
  end
end
