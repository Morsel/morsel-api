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
    subject(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
    subject(:first_morsel) { post_with_morsels.morsels.first }
    before do
      MorselPost.find_by(post: post_with_morsels, morsel: first_morsel).update(sort_order: 2)
    end

    it 'increments the sort_order for all Morsels after new sort_order' do
      expect(post_with_morsels.morsels.last.sort_order_for_post_id(post_with_morsels.id)).to eq(post_with_morsels.morsels.count + 1)
    end

    it 'sets the new sort_order' do
      expect(first_morsel.sort_order_for_post_id(post_with_morsels.id)).to eq(2)
    end
  end

  describe 'getting the the sort_order in a post' do
    subject(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
    subject(:first_morsel) { post_with_morsels.morsels.first }

    it 'returns the sort_order' do
      expect(first_morsel.sort_order_for_post_id(post_with_morsels.id)).to eq(1)
    end
  end

  describe '#url' do
    let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator) }
    let(:first_morsel) { post_with_morsels_and_creator.morsels.first }
    subject(:url) { first_morsel.url(post_with_morsels_and_creator) }

    it { should eq("https://test.eatmorsel.com/#{first_morsel.creator.username}/#{post_with_morsels_and_creator.id}-#{post_with_morsels_and_creator.cached_slug}/1") }
  end

  describe '#facebook_message' do
    let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator) }
    let(:first_morsel) { post_with_morsels_and_creator.morsels.first }
    subject(:facebook_message) { first_morsel.facebook_message(post_with_morsels_and_creator) }

    it { should include(first_morsel.url(post_with_morsels_and_creator)) }
    it { should include(post_with_morsels_and_creator.title) }
    it { should include(first_morsel.description) }
  end

  describe '#twitter_message' do
    let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator) }
    let(:first_morsel) { post_with_morsels_and_creator.morsels.first }
    subject(:twitter_message) { first_morsel.twitter_message(post_with_morsels_and_creator) }

    it { should include(first_morsel.url(post_with_morsels_and_creator)) }
    it { should include(post_with_morsels_and_creator.title) }
    it { should include(first_morsel.description[40]) } # Only bother checking the first 40 characters are included
  end
end
