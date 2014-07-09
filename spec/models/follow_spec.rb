# ## Schema Information
#
# Table name: `follows`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`follower_id`**      | `integer`          |
# **`followable_id`**    | `integer`          |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
# **`followable_type`**  | `string(255)`      |
# **`deleted_at`**       | `datetime`         |
#

require 'spec_helper'

describe Follow do
  subject(:user_follow) { FactoryGirl.build(:user_follow) }

  it { should respond_to(:follower) }
  it { should respond_to(:followable) }

  it_behaves_like 'Activityable' do
    let(:activityable_object) { user_follow }
  end

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:user_follow) }
    let(:user) { user_creatable_object.user }
  end

  context 'following two different types of objects with the same id' do
    let(:place_follow) { FactoryGirl.build(:place_follow, followable:FactoryGirl.create(:place, id:user_follow.followable_id), follower_id:user_follow.follower_id) }
    it 'should successfully follow both' do
      user_follow.save
      expect(user_follow).to be_valid
      expect(place_follow).to be_valid
    end
  end
end
