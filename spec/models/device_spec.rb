# ## Schema Information
#
# Table name: `devices`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`user_id`**     | `integer`          |
# **`name`**        | `string(255)`      |
# **`token`**       | `string(255)`      |
# **`model`**       | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

describe Device do
  pending "add some examples to (or delete) #{__FILE__}"
end
