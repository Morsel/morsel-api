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
  subject(:morsel_like) { FactoryGirl.build(:morsel_like, likeable: morsel) }
  let(:morsel) { Sidekiq::Testing.inline! { FactoryGirl.create(:morsel_with_creator) }}

  it_behaves_like 'Activityable'
  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'
  it_behaves_like 'UserCreatable' do
    let(:user) { subject.user }
  end

  it { should respond_to(:liker) }
  it { should respond_to(:likeable) }
end
