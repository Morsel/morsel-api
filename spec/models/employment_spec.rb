# ## Schema Information
#
# Table name: `employments`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`place_id`**    | `integer`          |
# **`user_id`**     | `integer`          |
# **`title`**       | `string(255)`      |
# **`deleted_at`**  | `datetime`         |
#

require 'spec_helper'

describe Employment do
  subject(:employment) { FactoryGirl.build(:employment) }

  it { should respond_to(:title) }
  it { should respond_to(:place) }
  it { should respond_to(:user) }
end
