# ## Schema Information
#
# Table name: `collection_morsels`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`collection_id`**  | `integer`          |
# **`morsel_id`**      | `integer`          |
# **`sort_order`**     | `integer`          |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection_morsel do
    association(:collection)
    association(:morsel)
  end
end
