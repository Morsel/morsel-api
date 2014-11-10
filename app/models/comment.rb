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
  include Authority::Abilities,
          Activityable,
          TimelinePaginateable,
          UserCreatable

  def self.activity_notification; true end
  def activity_subject; commentable end
  def additional_recipient_ids; commentable.commenter_ids - [commenter_id, commentable.creator_id] end

  acts_as_paranoid

  after_destroy :update_counter_caches
  after_save :update_counter_caches

  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: 'User'
  alias_attribute :creator, :commenter
  alias_attribute :user, :commenter

  self.authorizer_name = 'CommentAuthorizer'

  validates :commenter, presence: true
  validates :commentable, presence: true
  validates :description, presence: true

  private

  def update_counter_caches
    self.commentable.update comments_count: Comment.where(commentable_id:commentable_id, commentable_type:commentable_type).count
  end
end
