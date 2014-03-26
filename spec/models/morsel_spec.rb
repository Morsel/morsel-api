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
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`deleted_at`**          | `datetime`         |
# **`nonce`**               | `string(255)`      |
# **`photo_processing`**    | `boolean`          |
# **`post_id`**             | `integer`          |
# **`sort_order`**          | `integer`          |
#

require 'spec_helper'

describe Morsel do
  subject(:morsel) { FactoryGirl.build(:morsel) }

  it { should respond_to(:description) }
  it { should respond_to(:photo) }
  it { should respond_to(:nonce) }
  it { should respond_to(:sort_order) }

  it { should respond_to(:creator) }
  it { should respond_to(:post) }

  it { should be_valid }

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:morsel_with_creator) }
    let(:user) { user_creatable_object.creator }
  end

  context 'saved with creator' do
    subject(:morsel) { FactoryGirl.create(:morsel_with_creator) }

    it 'adds :creator Role to the creator' do
      expect(morsel.creator.has_role?(:creator, morsel)).to be_true
      expect(morsel.creator.can_update?(morsel)).to be_true
    end

    context 'with likes' do
      let(:likes_count) { rand(3..6) }
      before do
        likes_count.times do
          morsel.likers << FactoryGirl.create(:user)
        end
      end

      describe '.total_like_count' do
        it 'returns the number of likes for a Morsel' do
          expect(morsel.like_count).to eq(likes_count)
        end
      end
    end

    context 'with comments' do
      let(:comments_count) { rand(3..6) }
      before do
        comments_count.times do
          morsel.commenters << FactoryGirl.create(:user)
        end
      end

      describe '.total_comment_count' do
        it 'returns the number of comments for a Morsel' do
          expect(morsel.comment_count).to eq(comments_count)
        end
      end
    end
  end

  context 'post is missing' do
    before { morsel.post = nil }
    it { should_not be_valid }
  end

  describe 'changing the sort_order in a post' do
    subject(:post_with_morsels) { FactoryGirl.create(:post_with_morsels, morsels_count: 3) }
    subject(:first_morsel) { post_with_morsels.morsels.first }
    before do
      first_morsel.update(sort_order: 2)
    end

    it 'increments the sort_order for all Morsels after new sort_order' do
      expect(post_with_morsels.morsels.last.sort_order).to eq(post_with_morsels.morsels.count + 1)
    end

    it 'sets the new sort_order' do
      expect(first_morsel.sort_order).to eq(2)
    end
  end

  describe 'getting the the sort_order in a post' do
    subject(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
    subject(:first_morsel) { post_with_morsels.morsels.first }

    it 'returns the sort_order' do
      expect(first_morsel.sort_order).to eq(1)
    end
  end

  describe '#url' do
    let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
    let(:first_morsel) { post_with_morsels.morsels.first }
    subject(:url) { first_morsel.url }

    it { should eq("https://test.eatmorsel.com/#{first_morsel.creator.username}/#{post_with_morsels.id}-#{post_with_morsels.cached_slug}/1") }
  end

  describe '#facebook_message' do
    let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
    let(:first_morsel) { post_with_morsels.morsels.first }
    subject(:facebook_message) { first_morsel.facebook_message }

    it { should include(first_morsel.url) }
    it { should include(post_with_morsels.title) }
    it { should include(first_morsel.description) }
  end

  describe '#twitter_message' do
    let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
    let(:first_morsel) { post_with_morsels.morsels.first }
    subject(:twitter_message) { first_morsel.twitter_message }

    it { should include(first_morsel.url) }
    it { should include(post_with_morsels.title) }
    it { should include(first_morsel.description[40]) } # Only bother checking the first 40 characters are included
  end
end
