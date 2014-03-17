# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`title`**         | `string(255)`      |
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
# **`creator_id`**    | `integer`          |
# **`cached_slug`**   | `string(255)`      |
# **`deleted_at`**    | `datetime`         |
# **`draft`**         | `boolean`          | `default(FALSE), not null`
# **`published_at`**  | `datetime`         |
#

require 'spec_helper'

describe Post do
  subject(:post) { FactoryGirl.build(:post) }

  it { should respond_to(:title) }
  it { should respond_to(:cached_slug) }

  it { should respond_to(:creator) }
  it { should respond_to(:morsels) }
  it { should respond_to(:draft) }
  it { should respond_to(:published_at) }

  it { should be_valid }

  its(:morsels) { should be_empty }

  describe 'title' do
    context 'greater than 50 characters' do
      before do
        post.title = Faker::Lorem.characters(51)
      end

      it { should_not be_valid }
    end
  end

  describe 'published_at' do
    it 'should set published_at on save' do
      expect(post.published_at).to be_nil
      post.save
      expect(post.published_at).to_not be_nil
    end

    context 'draft' do
      before do
        post.draft = true
      end

      it 'should NOT set published_at on save' do
        expect(post.published_at).to be_nil
        post.save
        expect(post.published_at).to be_nil
      end
    end
  end

  context 'persisted' do
    before { post.save }

    its(:cached_slug) { should_not be_nil }

    context 'title changes' do
      let(:new_title) { 'Some New Title!' }
      before do
        @old_slug = post.cached_slug
        post.title = new_title
        post.save
      end

      it 'should update the slug' do
        expect(post.cached_slug.to_s).to eq('some-new-title')
      end

      it 'should still be searchable from it\'s old slug' do
        expect(Post.find_using_slug(@old_slug)).to_not be_nil
      end
    end
  end

  context 'has Morsels' do
    subject(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }

    its(:morsels) { should_not be_empty }

    it 'returns Morsels ordered by sort_order' do
      morsel_ids = post_with_morsels.morsel_ids
      post_with_morsels.morsels.last.update(sort_order: 1)

      expect(post_with_morsels.morsel_ids).to eq(morsel_ids.rotate!(-1))
    end

    describe 'Post gets destroyed' do
      it 'should destroy its Morsels' do
        post_with_morsels.destroy
        post_with_morsels.morsels.each do |morsel|
          expect(morsel.deleted?).to be_true
        end
      end
    end
  end
end
