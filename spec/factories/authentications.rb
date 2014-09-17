# ## Schema Information
#
# Table name: `authentications`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`provider`**    | `string(255)`      |
# **`uid`**         | `string(255)`      |
# **`user_id`**     | `integer`          |
# **`token`**       | `text`             |
# **`secret`**      | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`link`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
    link 'link'
    uid { Faker::Lorem.characters(10) }
    association :user

    factory :facebook_authentication do
      provider 'facebook'
      name 'facebook_name'
      uid { "fbuid_#{Faker::Number.number(10)}" }
      link 'facebook.com/facebook.user'
      token { Faker::Lorem.characters(20) }
    end

    factory :instagram_authentication do
      provider 'instagram'
      name 'instagram_screen_name'
      uid { "instauid_#{Faker::Number.number(10)}" }
      link 'instagram.com/twitter_screen_name'
      token { Faker::Lorem.characters(20) }
      secret { Faker::Lorem.characters(20) }
    end

    factory :twitter_authentication do
      provider 'twitter'
      name 'twitter_screen_name'
      uid { "tuid_#{Faker::Number.number(10)}" }
      link 'twitter.com/twitter_screen_name'
      token { Faker::Lorem.characters(20) }
      secret { Faker::Lorem.characters(20) }
    end
  end
end
