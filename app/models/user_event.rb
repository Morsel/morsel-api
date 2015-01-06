# ## Schema Information
#
# Table name: `user_events`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `integer`          | `not null, primary key`
# **`user_id`**         | `integer`          |
# **`name`**            | `string(255)`      |
# **`client_version`**  | `string(255)`      |
# **`client_device`**   | `string(255)`      |
# **`__utmz`**          | `text`             |
# **`created_at`**      | `datetime`         |
# **`updated_at`**      | `datetime`         |
# **`properties`**      | `hstore`           | `default({})`
#

class UserEvent < ActiveRecord::Base
end
