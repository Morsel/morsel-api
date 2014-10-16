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

  it_behaves_like 'Activityable'
  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'
  it_behaves_like 'UserCreatable' do
    let(:user) { subject.user }
  end

  it { should respond_to(:liker) }
  it { should respond_to(:likeable) }

end
