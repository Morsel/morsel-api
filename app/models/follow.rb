# ## Schema Information
#
# Table name: `follows`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`follower_id`**      | `integer`          |
# **`followable_id`**    | `integer`          |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`followable_type`**  | `string(255)`      |
# **`deleted_at`**       | `datetime`         |
#

class Follow < ActiveRecord::Base
  include Authority::Abilities, UserCreatable

  include Activityable
  def self.activity_notification; true end
  def subject; followable end

  acts_as_paranoid

  belongs_to :followable, polymorphic: true
  belongs_to :follower, class_name: 'User'
  alias_attribute :creator, :follower
  alias_attribute :user, :follower

  validates :follower_id, uniqueness: { scope: [:deleted_at, :followable_id] }
  validates :followable, presence: true

  def followable_type=(sType)
    base_class = sType.constantize.try(:base_class)
    if base_class
      super(base_class.to_s)
    else
      super(sType)
    end
  end
end
