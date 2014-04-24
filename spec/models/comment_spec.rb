# ## Schema Information
#
# Table name: `comments`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `integer`          | `not null, primary key`
# **`commenter_id`**      | `integer`          |
# **`commentable_id`**    | `integer`          |
# **`description`**       | `text`             |
# **`deleted_at`**        | `datetime`         |
# **`created_at`**        | `datetime`         |
# **`updated_at`**        | `datetime`         |
# **`commentable_type`**  | `string(255)`      |
#

require 'spec_helper'

describe Comment do
  subject(:item_comment) { FactoryGirl.build(:item_comment) }

  it { should respond_to(:commenter) }
  it { should respond_to(:commentable) }
  it { should respond_to(:description) }

  it_behaves_like 'Activityable' do
    let(:activityable_object) { item_comment }
  end

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:item_comment) }
    let(:user) { user_creatable_object.user }
  end
end
