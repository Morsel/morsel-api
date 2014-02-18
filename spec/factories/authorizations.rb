# ## Schema Information
#
# Table name: `authorizations`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`provider`**    | `string(255)`      |
# **`uid`**         | `string(255)`      |
# **`user_id`**     | `integer`          |
# **`token`**       | `string(255)`      |
# **`secret`**      | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`link`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authorization do
    link 'link'
    uid { Faker::Lorem.characters(10) }
    association :user

    factory :facebook_authorization do
      provider 'facebook'
      name 'facebook.user'
      link 'facebook.com/facebook.user'
      token { Faker::Lorem.characters(20) }
    end

    factory :twitter_authorization do
      provider 'twitter'
      name 'twitter_screen_name'
      link 'twitter.com/twitter_screen_name'
      token { Faker::Lorem.characters(20) }
      secret { Faker::Lorem.characters(20) }
    end
  end
end
