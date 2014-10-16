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

  it_behaves_like 'Activityable'
  it_behaves_like 'Timestamps'
  it_behaves_like 'UserCreatable' do
    let(:user) { subject.user }
  end

  it { should respond_to(:commenter) }
  it { should respond_to(:commentable) }
  it { should respond_to(:description) }
end
