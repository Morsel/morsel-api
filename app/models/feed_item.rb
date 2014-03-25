# ## Schema Information
#
# Table name: `feed_items`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`subject_id`**    | `integer`          |
# **`subject_type`**  | `string(255)`      |
# **`deleted_at`**    | `datetime`         |
# **`visible`**       | `boolean`          | `default(FALSE)`
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
#

class FeedItem < ActiveRecord::Base
  include TimelinePaginateable
  acts_as_paranoid

  belongs_to :subject, polymorphic: true

  scope :visible_items, -> { where(visible: true) }
end
