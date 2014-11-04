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
# **`provider`**                | `string(255)`      |
# **`uid`**                     | `string(255)`      |
# **`username`**                | `string(255)`      |
# **`bio`**                     | `string(255)`      |
# **`active`**                  | `boolean`          | `default(TRUE)`
# **`verified_at`**             | `datetime`         |
# **`industry`**                | `string(255)`      |
# **`photo_processing`**        | `boolean`          |
# **`staff`**                   | `boolean`          | `default(FALSE)`
# **`deleted_at`**              | `datetime`         |
# **`promoted`**                | `boolean`          | `default(FALSE)`
# **`settings`**                | `hstore`           | `default({})`
# **`professional`**            | `boolean`          | `default(FALSE)`
# **`password_set`**            | `boolean`          | `default(TRUE)`
# **`drafts_count`**            | `integer`          | `default(0), not null`
# **`followed_users_count`**    | `integer`          | `default(0), not null`
# **`followers_count`**         | `integer`          | `default(0), not null`
#

module Search
  class SearchableUser < User
    scope :search_first_name, -> (search_first_name) { where(SearchableUser.arel_table[:first_name].matches("#{search_first_name}%")) if search_first_name.present? }
    scope :search_last_name, -> (search_last_name) { where(SearchableUser.arel_table[:last_name].matches("#{search_last_name}%")) if search_last_name.present? }
    scope :search_username, -> (search_username) { where(SearchableUser.arel_table[:username].matches("#{search_username}%")) if search_username.present? }
    scope :search_query, -> (search_query) { where(
      Arel::Nodes::NamedFunction.new('concat', [SearchableUser.arel_table[:first_name], ' ', SearchableUser.arel_table[:last_name]]).matches(search_query)
      .or(SearchableUser.arel_table[:username].matches(search_query))
      ) if search_query.present?
    }
    scope :search_promoted, -> (search_promoted) { where('promoted = ?', search_promoted) if search_promoted.present? }
  end
end
