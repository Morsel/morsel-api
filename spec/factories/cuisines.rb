# ## Schema Information
#
# Table name: `cuisines`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`name`**        | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

FactoryGirl.define do
  factory :cuisine do
    name { "cuisine_#{Faker::Lorem.characters(10)}" }
  end
end
