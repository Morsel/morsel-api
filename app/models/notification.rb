# ## Schema Information
#
# Table name: `notifications`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `integer`          | `not null, primary key`
# **`payload_id`**      | `integer`          |
# **`payload_type`**    | `string(255)`      |
# **`message`**         | `string(255)`      |
# **`user_id`**         | `integer`          |
# **`marked_read_at`**  | `datetime`         |
# **`deleted_at`**      | `datetime`         |
# **`created_at`**      | `datetime`         |
# **`updated_at`**      | `datetime`         |
#

class Notification < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable

  acts_as_paranoid
  belongs_to :payload, polymorphic: true
  belongs_to :user

  scope :unread, -> { where(marked_read_at: nil) }
  scope :unread_for_user_id, -> (user_id) { unread.where(user_id: user_id) }

  self.authorizer_name = 'NotificationAuthorizer'

  def read?
    marked_read_at.present?
  end

  def mark_read!
    update(marked_read_at: DateTime.now) unless marked_read_at
  end
end
