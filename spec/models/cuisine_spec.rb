# ## Schema Information
#
# Table name: `cuisines`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`name`**        | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

describe Cuisine do
  subject(:cuisine) { FactoryGirl.build(:cuisine) }

  it { should respond_to(:name) }
  it { should respond_to(:deleted_at) }
end
