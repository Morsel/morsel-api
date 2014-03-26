require 'spec_helper'

describe 'Feed API' do
  describe 'GET /feed' do
    let(:endpoint) { '/feed' }
    let(:user) { FactoryGirl.create(:user) }
    let(:posts_count) { 3 }

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { FeedItem }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:visible_post_feed_item) }
      end
    end

    before do
      posts_count.times { Sidekiq::Testing.inline! { FactoryGirl.create(:post_with_morsels) } }
    end

    it 'returns the Feed' do
      get endpoint, api_key: api_key_for_user(user), format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(posts_count)

      first_feed_item = json_data.first
      expect(first_feed_item['subject_type']).to eq('Post')

      # Since the feed call returns the newest first, compare against the last Post
      expect_json_keys(first_feed_item['subject'], Post.last, %w(id title draft))
    end

    it 'should be public' do
      get endpoint, format: :json

      expect(response).to be_success
    end

    context 'Post is deleted' do
      before do
        Post.last.destroy
      end

      it 'removes the Feed Item' do
        get endpoint, api_key: api_key_for_user(user),
                 format: :json
        expect(response).to be_success
        expect(json_data.count).to eq(posts_count - 1)
      end
    end

    context 'Post is marked as draft' do
      before do
        Post.last.update(draft: true)
      end

      it 'omits the Feed Item' do
        get endpoint, api_key: api_key_for_user(user),
                 format: :json

        expect(response).to be_success
        expect(json_data.count).to eq(posts_count - 1)
      end
    end
  end
end
