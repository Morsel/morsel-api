# ## Schema Information
#
# Table name: `keywords`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`type`**        | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Specialty < Keyword
end
