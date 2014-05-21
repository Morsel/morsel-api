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

require 'spec_helper'

describe Keyword do
  subject(:cuisine) { FactoryGirl.build(:cuisine) }

  it { should respond_to(:name) }
end
