# ## Schema Information
#
# Table name: `comments`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`user_id`**      | `integer`          |
# **`morsel_id`**    | `integer`          |
# **`description`**  | `text`             |
# **`deleted_at`**   | `datetime`         |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
#

class Comment < ActiveRecord::Base
  include Authority::Abilities
  include TimelinePaginateable
  include UserCreatable

  include Activityable
  def self.activity_notification; true end
  def subject; morsel end

  acts_as_paranoid

  belongs_to :morsel
  belongs_to :user
  alias_attribute :creator, :user

  self.authorizer_name = 'CommentAuthorizer'
end
