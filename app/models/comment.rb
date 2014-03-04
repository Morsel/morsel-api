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
  self.authorizer_name = 'CommentAuthorizer'
  acts_as_paranoid
  resourcify

  belongs_to :user
  belongs_to :morsel

  include TimelinePaginateable
end
