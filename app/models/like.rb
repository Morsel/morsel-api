# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`liker_id`**       | `integer`          |
# **`likeable_id`**    | `integer`          |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`likeable_type`**  | `string(255)`      |
#

class Like < ActiveRecord::Base
  include Authority::Abilities
  include UserCreatable

  include Activityable
  def self.activity_notification; true end
  def subject; likeable end

  acts_as_paranoid

  belongs_to :likeable, polymorphic: true
  belongs_to :liker, class_name: 'User'
  alias_attribute :creator, :liker
  alias_attribute :user, :liker

  self.authorizer_name = 'LikeAuthorizer'

  validates :liker_id, uniqueness: { scope: [:deleted_at, :likeable_id] }
  validates :likeable, presence: true
end
