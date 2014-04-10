# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`user_id`**     | `integer`          |
# **`item_id`**     | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

describe Like do
  subject(:like) { FactoryGirl.build(:like) }

  it { should respond_to(:user) }
  it { should respond_to(:item) }

  it_behaves_like 'Activityable' do
    let(:activityable_object) { like }
  end

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:like) }
    let(:user) { user_creatable_object.user }
  end
end
