# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`title`**               | `string(255)`      |
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`cached_slug`**         | `string(255)`      |
# **`deleted_at`**          | `datetime`         |
# **`draft`**               | `boolean`          | `default(TRUE), not null`
# **`published_at`**        | `datetime`         |
# **`primary_item_id`**     | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`mrsl`**                | `hstore`           |
# **`place_id`**            | `integer`          |
# **`template_id`**         | `integer`          |
#

require 'spec_helper'

describe Morsel do
  subject(:morsel) { FactoryGirl.build(:morsel) }

  it { should respond_to(:title) }
  it { should respond_to(:cached_slug) }
  it { should respond_to(:draft) }
  it { should respond_to(:published_at) }
  it { should respond_to(:primary_item_id) }
  it { should respond_to(:primary_item) }
  it { should respond_to(:photo) }
  it { should respond_to(:template_id) }

  it { should respond_to(:creator) }
  it { should respond_to(:items) }

  it { should respond_to(:total_like_count) }
  it { should respond_to(:total_comment_count) }

  it { should be_valid }

  its(:items) { should be_empty }

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:morsel_with_creator) }
    let(:user) { user_creatable_object.creator }
  end

  describe 'title' do
    context 'greater than 50 characters' do
      before do
        morsel.title = Faker::Lorem.characters(51)
      end

      it { should_not be_valid }
    end
  end

  describe 'published_at' do
    it 'should set published_at on save' do
      expect(morsel.published_at).to be_nil
      morsel.save
      expect(morsel.published_at).to_not be_nil
    end

    context 'draft' do
      before do
        morsel.draft = true
      end

      it 'should NOT set published_at on save' do
        expect(morsel.published_at).to be_nil
        morsel.save
        expect(morsel.published_at).to be_nil
      end
    end
  end

  context :saved do
    before { morsel.save }

    its(:cached_slug) { should_not be_nil }

    context 'title changes' do
      let(:new_title) { 'Some New Title!' }
      before do
        @old_slug = morsel.cached_slug
        morsel.title = new_title
        morsel.save
      end

      it 'should update the slug' do
        expect(morsel.cached_slug.to_s).to eq('some-new-title')
      end

      it 'should still be searchable from it\'s old slug' do
        expect(Morsel.find_using_slug(@old_slug)).to_not be_nil
      end
    end
  end

  describe '#url' do
    let(:morsel_with_creator) { FactoryGirl.build(:morsel_with_creator) }
    subject(:url) { morsel_with_creator.url }

    it { should eq("https://test.eatmorsel.com/#{morsel_with_creator.creator.username}/#{morsel_with_creator.id}-#{morsel_with_creator.cached_slug}") }
  end

  describe '#facebook_message' do
    let(:morsel_with_creator) { FactoryGirl.create(:morsel_with_creator) }
    subject(:facebook_message) { SocialMorselDecorator.new(morsel_with_creator).facebook_message }

    it { should include(morsel_with_creator.title) }
    it { should include(morsel_with_creator.facebook_mrsl) }
    it { should include(' via Morsel') }
  end

  describe '#twitter_message' do
    let(:morsel_with_creator) { FactoryGirl.create(:morsel_with_creator) }
    subject(:twitter_message) { SocialMorselDecorator.new(morsel_with_creator).twitter_message }

    it { should include(morsel_with_creator.title) }
    it { should include(morsel_with_creator.twitter_mrsl) }
    it { should include(' via @eatmorsel') }
  end

  context 'has Items' do
    subject(:morsel_with_items) { Sidekiq::Testing.inline! { FactoryGirl.create(:morsel_with_items) }}

    its(:items) { should_not be_empty }

    it 'returns Items ordered by sort_order' do
      item_ids = morsel_with_items.item_ids
      morsel_with_items.items.last.update(sort_order: 1)

      expect(morsel_with_items.item_ids).to eq(item_ids.rotate!(-1))
    end

    describe 'Morsel gets destroyed' do
      it 'should destroy its Items' do
        morsel_with_items.destroy
        morsel_with_items.items.each do |item|
          expect(item.destroyed?).to be_true
        end
      end

      it 'should destroy its FeedItem' do
        feed_item = morsel_with_items.feed_item
        morsel_with_items.destroy
        expect(feed_item.destroyed?).to be_true
      end
    end

    context 'with likes' do
      let(:likes_count) { rand(3..6) }
      before do
        likes_count.times do
          morsel_with_items.items.sample.likers << FactoryGirl.create(:user)
        end
      end

      describe '.total_like_count' do
        it 'returns the total number of likes for all Items in a Morsel' do
          expect(morsel_with_items.total_like_count).to eq(likes_count)
        end
      end
    end

    context 'primary_item gets destroyed' do
      before do
        morsel_with_items.primary_item.destroy
        morsel_with_items.reload
      end
      it 'should nil the primary_item_id' do
        expect(morsel_with_items.primary_item_id).to be_nil
      end
    end

    context 'with comments' do
      let(:comments_count) { rand(3..6) }
      before do
        comments_count.times { Comment.create(commenter: FactoryGirl.create(:user), commentable: morsel_with_items.items.sample, description: Faker::Lorem.sentence(rand(1..3))) }
      end

      describe '.total_comment_count' do
        it 'returns the total number of comments for all Items in a Morsel' do
          expect(morsel_with_items.total_comment_count).to eq(comments_count)
        end
      end
    end
  end
end
