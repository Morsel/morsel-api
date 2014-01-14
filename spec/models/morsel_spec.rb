# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`description`**         | `text`             |
# **`like_count`**          | `integer`          | `default(0), not null`
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`deleted_at`**          | `datetime`         |
#

require 'spec_helper'

describe Morsel do
  subject(:morsel) { FactoryGirl.build(:morsel) }

  it { should respond_to(:description) }
  it { should respond_to(:photo) }

  it { should respond_to(:creator) }
  it { should respond_to(:morsel_posts) }
  it { should respond_to(:posts) }

  it { should be_valid }

  describe 'description and photo are missing' do
    subject(:morsel_without_description_and_photo) { FactoryGirl.build(:morsel_without_description_and_photo) }

    it { should_not be_valid }
  end

  describe 'changing the sort_order in a post' do
    before do
      @post = FactoryGirl.create(:post_with_morsels)
      @first_morsel = @post.morsels.first
      @first_morsel.change_sort_order_for_post_id(@post.id, 2)
    end

    it 'increments the sort_order for all Morsels after new sort_order' do
      expect(@post.morsels.last.sort_order_for_post_id(@post.id)).to eq(@post.morsels.count + 1)
    end

    it 'sets the new sort_order' do
      expect(@first_morsel.sort_order_for_post_id(@post.id)).to eq(2)
    end
  end

  describe 'getting the the sort_order in a post' do
    before do
      @post = FactoryGirl.create(:post_with_morsels)
      @first_morsel = @post.morsels.first
    end

    it 'returns the sort_order' do
      expect(@first_morsel.sort_order_for_post_id(@post.id)).to eq(1)
    end
  end
end
