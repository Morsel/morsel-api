# ## Schema Information
#
# Table name: `relationships`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`follower_id`**  | `integer`          |
# **`followed_id`**  | `integer`          |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
#

class Relationship < ActiveRecord::Base
  include Authority::Abilities
  # TODO: Eventually use UserCreatable to track who created the Relationship
  # TODO: Rename this to follow, so it can match Like and Comment as an activity and lowercase + past tense for notification message
end
