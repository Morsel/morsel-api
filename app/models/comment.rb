# ## Schema Information
#
# Table name: `comments`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `integer`          | `not null, primary key`
# **`commenter_id`**      | `integer`          |
# **`commentable_id`**    | `integer`          |
# **`description`**       | `text`             |
# **`deleted_at`**        | `datetime`         |
# **`created_at`**        | `datetime`         |
# **`updated_at`**        | `datetime`         |
# **`commentable_type`**  | `string(255)`      |
#

class Comment < ActiveRecord::Base
  include Authority::Abilities
  include TimelinePaginateable
  include UserCreatable

  include Activityable
  def self.activity_notification; true end
  def subject; commentable end

  acts_as_paranoid

  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: 'User'
  alias_attribute :creator, :commenter
  alias_attribute :user, :commenter

  self.authorizer_name = 'CommentAuthorizer'

  validates :commenter, presence: true
  validates :commentable, presence: true
  validates :description, presence: true
end
