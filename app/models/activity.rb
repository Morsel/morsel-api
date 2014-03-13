# ## Schema Information
#
# Table name: `activities`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`subject_id`**       | `integer`          |
# **`subject_type`**     | `string(255)`      |
# **`action_id`**        | `integer`          |
# **`action_type`**      | `string(255)`      |
# **`creator_id`**       | `integer`          |
# **`recipient_id`**     | `integer`          |
# **`notification_id`**  | `integer`          |
# **`deleted_at`**       | `datetime`         |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
#

class Activity < ActiveRecord::Base
  include TimelinePaginateable

  acts_as_paranoid
  belongs_to :action, polymorphic: true
  belongs_to :subject, polymorphic: true
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id'
  has_one :notification, as: :payload, dependent: :destroy
end
