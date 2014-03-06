# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `integer`          | `not null, primary key`
# **`email`**                   | `string(255)`      | `default(""), not null`
# **`encrypted_password`**      | `string(255)`      | `default(""), not null`
# **`reset_password_token`**    | `string(255)`      |
# **`reset_password_sent_at`**  | `datetime`         |
# **`remember_created_at`**     | `datetime`         |
# **`sign_in_count`**           | `integer`          | `default(0), not null`
# **`current_sign_in_at`**      | `datetime`         |
# **`last_sign_in_at`**         | `datetime`         |
# **`current_sign_in_ip`**      | `string(255)`      |
# **`last_sign_in_ip`**         | `string(255)`      |
# **`created_at`**              | `datetime`         |
# **`updated_at`**              | `datetime`         |
# **`first_name`**              | `string(255)`      |
# **`last_name`**               | `string(255)`      |
# **`admin`**                   | `boolean`          | `default(FALSE), not null`
# **`authentication_token`**    | `string(255)`      |
# **`photo`**                   | `string(255)`      |
# **`photo_content_type`**      | `string(255)`      |
# **`photo_file_size`**         | `string(255)`      |
# **`photo_updated_at`**        | `datetime`         |
# **`title`**                   | `string(255)`      |
# **`provider`**                | `string(255)`      |
# **`uid`**                     | `string(255)`      |
# **`username`**                | `string(255)`      |
# **`bio`**                     | `string(255)`      |
# **`active`**                  | `boolean`          | `default(TRUE)`
# **`verified_at`**             | `datetime`         |
# **`type`**                    | `string(255)`      | `default("User")`
# **`unsubscribed`**            | `boolean`          | `default(FALSE)`
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    username { "user_#{Faker::Lorem.characters(10)}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password 'password'
    bio 'Hi! I like turtles!'

    factory :chef, class: User do
      industry 'chef'

      factory :chef_with_facebook_authorization do
        after(:create) do |chef|
          create_list(:facebook_authorization, 1, user: chef)
        end
      end

      factory :chef_with_twitter_authorization do
        after(:create) do |chef|
          create_list(:twitter_authorization, 1, user: chef)
        end
      end
    end

    factory :user_with_posts do
      ignore do
        posts_count 3
      end

      after(:create) do |user, evaluator|
        create_list(:post_with_morsels, evaluator.posts_count, creator: user)
      end
    end
  end

  factory :turd_ferg, class: User do
    email 'turdferg@eatmorsel.com'
    username 'turdferg'
    first_name 'Turd'
    last_name 'Ferguson'
    password 'test1234'
    title 'Suck it Trebek'
  end
end
