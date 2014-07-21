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
  belongs_to :place
  belongs_to :user

  scope :visible, -> { where(visible: true) }
  scope :featured, -> { where(featured: true) }
  scope :personalized_for, -> (user_id) {
    where(
      FeedItem.arel_table[:user_id].in(
        Follow.select(:followable_id).where(
          Follow.arel_table[:follower_id].eq(user_id)
          .and(Follow.arel_table[:followable_type].eq('User'))
          .and(Follow.arel_table[:deleted_at].eq(nil))
        ).ast
      ).or(FeedItem.arel_table[:place_id].in(
        Follow.select(:followable_id).where(
          Follow.arel_table[:follower_id].eq(user_id)
          .and(Follow.arel_table[:followable_type].eq('Place'))
          .and(Follow.arel_table[:deleted_at].eq(nil))
        ).ast
      )).or(FeedItem.arel_table[:user_id].eq(user_id)
      ).or(FeedItem.arel_table[:featured].eq(true))
    )
  }
end
