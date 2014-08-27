# ## Schema Information
#
# Table name: `employments`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`place_id`**    | `integer`          |
# **`user_id`**     | `integer`          |
# **`title`**       | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Employment < ActiveRecord::Base
  include Authority::Abilities, UserCreatable
  acts_as_paranoid

  belongs_to :place
  belongs_to :user

  self.authorizer_name = 'ProfessionalAuthorizer'

  validates :user_id, uniqueness: { scope: [:place_id], conditions: -> { where(deleted_at: nil) } }
end
