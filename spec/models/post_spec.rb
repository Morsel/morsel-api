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

  describe 'with Morsels' do
    before do
      @post = FactoryGirl.create(:post_with_morsels)
    end

    it 'returns Morsels ordered by sort_order' do
      morsel_ids = @post.morsel_ids
      @post.morsels.last.change_sort_order_for_post_id(@post.id, 1)
      expect(@post.morsel_ids).to eq(morsel_ids.rotate!(-1))
    end
  end
end
