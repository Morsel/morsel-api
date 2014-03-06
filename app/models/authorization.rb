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

class Authorization < ActiveRecord::Base
  include Authority::Abilities
  include TimelinePaginateable
  include UserCreatable

  belongs_to :user

  validates :provider,  allow_blank: false,
                        inclusion: %w(facebook twitter),
                        presence: true

  validates :secret, presence: true, if: proc { |a| a.provider == 'twitter' }
  validates :token, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :user, presence: true
end
