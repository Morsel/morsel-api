# ## Schema Information
#
# Table name: `keywords`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`type`**        | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Keyword < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable
  acts_as_paranoid

  has_many :tags, dependent: :destroy
  has_many :tagged_users, through: :tags, source: :taggable, source_type: 'User'
  alias_attribute :users, :tagged_users

  validates :name,
            presence: true
end
