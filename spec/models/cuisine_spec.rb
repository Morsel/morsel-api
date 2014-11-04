# ## Schema Information
#
# Table name: `keywords`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`type`**             | `string(255)`      |
# **`name`**             | `string(255)`      |
# **`deleted_at`**       | `datetime`         |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`followers_count`**  | `integer`          | `default(0), not null`
#

require 'spec_helper'

describe Cuisine do
  subject(:cuisine) { FactoryGirl.build(:cuisine) }

  it_behaves_like 'Timestamps'

  it { should respond_to(:name) }
  it { should respond_to(:deleted_at) }
end
