# ## Schema Information
#
# Table name: `posts`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`title`**        | `string(255)`      |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`creator_id`**   | `integer`          |
# **`cached_slug`**  | `string(255)`      |
# **`deleted_at`**   | `datetime`         |
#

require 'spec_helper'

describe Post do
  subject(:post) { FactoryGirl.build(:post) }

  it { should respond_to(:title) }
  it { should respond_to(:cached_slug) }

  it { should respond_to(:creator) }
  it { should respond_to(:morsel_posts) }
  it { should respond_to(:morsels) }

  it { should be_valid }

  its(:morsels) { should be_empty }

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

  describe 'with Morsels' do
    subject(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }

    its(:morsels) { should_not be_empty }

    it 'returns Morsels ordered by sort_order' do
      morsel_ids = post_with_morsels.morsel_ids
      post_with_morsels.set_sort_order_for_morsel(post_with_morsels.morsels.last.id, 1)
      expect(post_with_morsels.morsel_ids).to eq(morsel_ids.rotate!(-1))
    end
  end
end
