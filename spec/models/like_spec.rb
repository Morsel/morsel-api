# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`liker_id`**       | `integer`          |
# **`likeable_id`**    | `integer`          |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`likeable_type`**  | `string(255)`      |
#

require 'spec_helper'

describe Like do
  subject(:item_like) { FactoryGirl.build(:item_like) }

  it { should respond_to(:liker) }
  it { should respond_to(:likeable) }

  it_behaves_like 'Activityable' do
    let(:activityable_object) { item_like }
  end

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:item_like) }
    let(:user) { user_creatable_object.user }
  end
end
