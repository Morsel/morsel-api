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
# **`user_id`**       | `integer`          |
# **`featured`**      | `boolean`          | `default(FALSE)`
# **`place_id`**      | `integer`          |
#

class FeedItem < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable
  acts_as_paranoid

  belongs_to :subject, polymorphic: true
  belongs_to :user

  scope :visible, -> { where(visible: true) }
  scope :featured, -> { where(featured: true) }

  def self.personalized_for(user_id)
    where(%Q[
      user_id IN (SELECT followable_id
                  FROM follows
                  WHERE follower_id = :user_id
                    AND followable_type = 'User'
                    AND deleted_at IS NULL)
      OR user_id = :user_id
      OR featured = true
      ], user_id: user_id)
  end
end
