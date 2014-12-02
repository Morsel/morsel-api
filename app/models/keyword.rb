# ## Schema Information
#
# Table name: `keywords`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`type`**             | `string(255)`      |
# **`name`**             | `string(255)`      |
# **`deleted_at`**       | `datetime`         |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`followers_count`**  | `integer`          | `default(0), not null`
# **`promoted`**         | `boolean`          | `default(FALSE)`
# **`tags_count`**       | `integer`          | `default(0), not null`
#

class Keyword < ActiveRecord::Base
  VALID_TYPES = %w(
    Cuisine
    FoodAndDrink
    Hashtag
    Specialty
  )

  include Authority::Abilities,
          Followable,
          TimelinePaginateable

  acts_as_paranoid

  has_many :tags, dependent: :destroy
  has_many :tagged_users, through: :tags, source: :taggable, source_type: 'User'
  alias_attribute :users, :tagged_users

  validates :name,
            presence: true

  validates :type,  allow_blank: false,
                    inclusion: VALID_TYPES,
                    presence: true
end
