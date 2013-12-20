# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`description`**  | `text`             |
# **`like_count`**   | `integer`          | `default(0), not null`
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`user_id`**      | `integer`          |
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :morsel do
    description 'MyText'
    like_count 0
  end
end
