# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`title`**       | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`creator_id`**  | `integer`          |
#

require 'spec_helper'

describe Post do
  before do
    @post = FactoryGirl.build(:post)
  end

  subject { @post }

  it { should respond_to(:title) }

  it { should respond_to(:creator) }
  it { should respond_to(:morsel_posts) }
  it { should respond_to(:morsels) }

  it { should be_valid }

  its(:morsels) { should be_empty }

  describe 'with Morsels' do
    before { @post_with_morsels = FactoryGirl.create(:post_with_morsels) }
    subject { @post_with_morsels }

    its(:morsels) { should_not be_empty }

    it 'returns Morsels ordered by sort_order' do
      morsel_ids = @post_with_morsels.morsel_ids
      @post_with_morsels.morsels.last.change_sort_order_for_post_id(@post_with_morsels.id, 1)
      expect(@post_with_morsels.morsel_ids).to eq(morsel_ids.rotate!(-1))
    end
  end
end
