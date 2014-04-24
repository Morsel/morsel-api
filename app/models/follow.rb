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
#

class Follow < ActiveRecord::Base
  include Authority::Abilities
  # TODO: Eventually use UserCreatable to track who created the Relationship

  belongs_to :followable, polymorphic: true
  belongs_to :follower, class_name: 'User'
  alias_attribute :creator, :follower
  alias_attribute :user, :follower

end
