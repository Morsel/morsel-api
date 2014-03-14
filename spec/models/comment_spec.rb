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

require 'spec_helper'

describe Comment do
  subject(:comment) { FactoryGirl.build(:comment) }

  it { should respond_to(:user) }
  it { should respond_to(:morsel) }
  it { should respond_to(:description) }

  it_behaves_like 'Activityable' do
    let(:activityable_object) { comment }
  end
end
