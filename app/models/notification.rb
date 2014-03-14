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
  include TimelinePaginateable

  acts_as_paranoid
  belongs_to :payload, polymorphic: true
  belongs_to :user

  before_save :ensure_marked_read_at

  private

  # HACK: Since we're not going to implement 'Mark as Read' now, default all Notifications to being read upon creation
  def ensure_marked_read_at
    self.marked_read_at = DateTime.now if marked_read_at.blank?
  end
end
