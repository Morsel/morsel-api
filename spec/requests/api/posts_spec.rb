require 'spec_helper'

describe 'Posts API' do
  let(:chef) { FactoryGirl.create(:chef) }
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
  let(:morsels_count) { 4 }

  describe 'GET /posts posts#index' do
    let(:posts_count) { 3 }

    before do
      posts_count.times { FactoryGirl.create(:post_with_morsels, morsels_count: morsels_count) }
    end

    it 'returns a list of Posts' do
      get '/posts', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(posts_count)

      first_post = json_data.first

      expect(first_post['morsels'].count).to eq(morsels_count)
      expect(first_post['total_like_count']).to_not be_nil
      expect(first_post['total_comment_count']).to_not be_nil

      first_morsel = first_post['morsels'].first
      expect(first_morsel['like_count']).to_not be_nil
      expect(first_morsel['comment_count']).to_not be_nil
    end

    it 'returns liked for each Morsel' do
      get '/posts', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      first_morsel = json_data.first['morsels'].first
      expect(first_morsel['liked']).to_not be_nil
    end

    it 'returns post_id, sort_order, and url for each Morsel' do
      get '/posts', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      first_morsel = json_data.first['morsels'].first
      expect(first_morsel['post_id']).to_not be_nil
      expect(first_morsel['sort_order']).to_not be_nil
      expect(first_morsel['url']).to_not be_nil
    end

    it 'should be public' do
      get '/posts', format: :json

      expect(response).to be_success
    end

    context 'has drafts' do
      let(:draft_posts_count) { rand(3..6) }
      before do
        draft_posts_count.times { FactoryGirl.create(:draft_post_with_morsels) }
      end

      it 'should NOT include drafts' do
        get '/posts', api_key: api_key_for_user(turd_ferg),
                      format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(posts_count)
      end
    end

    context 'pagination' do
      before do
        30.times { FactoryGirl.create(:post_with_creator) }
      end

      describe 'max_id' do
        it 'returns results up to and including max_id' do
          expected_count = rand(3..6)
          max_id = Post.first.id + expected_count - 1
          get '/posts', api_key: api_key_for_user(turd_ferg),
                        max_id: max_id,
                        format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.first['id']).to eq(max_id)
        end
      end

      describe 'since_id' do
        it 'returns results since since_id' do
          expected_count = rand(3..6)
          since_id = Post.last.id - expected_count
          get '/posts', api_key: api_key_for_user(turd_ferg),
                        since_id: since_id,
                        format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.last['id']).to eq(since_id + 1)
        end
      end

      describe 'count' do
        it 'defaults to 20' do
          get '/posts', api_key: api_key_for_user(turd_ferg),
                        format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(20)
        end

        it 'limits the result' do
          expected_count = rand(3..6)
          get '/posts', api_key: api_key_for_user(turd_ferg),
                        count: expected_count,
                        format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
        end
      end
    end

    context 'user_id included in parameters' do
      let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }

      it 'returns all Posts for user_id' do
        get '/posts', api_key: api_key_for_user(turd_ferg),
                      user_id_or_username: post_with_morsels.creator.id,
                      format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(1)

        creator_id = post_with_morsels.creator.id

        json_data.each do |morsel_json|
          expect(morsel_json['creator_id']).to eq(creator_id)
        end
      end
    end
  end

  describe 'POST /posts posts#create', sidekiq: :inline do
    let(:expected_title) { 'Bake Sale!' }

    it 'creates a Post' do
      post '/posts',  api_key: api_key_for_user(chef),
                      format: :json,
                      post: {
                        title: expected_title
                      }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_post = Post.find json_data['id']
      expect_json_keys(json_data, new_post, %w(id title creator_id))
      expect(json_data['title']).to eq(expected_title)
      expect(new_post.draft).to be_false
    end

    context 'draft is set to true' do
      it 'creates a draft Post' do
        post '/posts',  api_key: api_key_for_user(chef),
                        format: :json,
                        post: {
                          title: expected_title,
                          draft: true
                        }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        new_post = Post.find json_data['id']
        expect_json_keys(json_data, new_post, %w(id title creator_id))
        expect(json_data['title']).to eq(expected_title)
        expect(new_post.draft).to be_true
      end
    end
  end

  describe 'GET /posts posts#show' do
    let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels, morsels_count: morsels_count) }

    it 'returns the Post' do
      get "/posts/#{post_with_morsels.id}", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, post_with_morsels, %w(id title creator_id))
      expect(json_data['slug']).to eq(post_with_morsels.cached_slug)

      expect(json_data['morsels'].count).to eq(morsels_count)
    end

    it 'should be public' do
      get "/posts/#{post_with_morsels.id}", format: :json

      expect(response).to be_success
    end
  end

  describe 'PUT /posts/{:post_id} posts#update' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels, creator: turd_ferg) }
    let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

    it 'updates the Post' do
      put "/posts/#{existing_post.id}", api_key: api_key_for_user(turd_ferg),
                                        format: :json,
                                        post: { title: new_title }

      expect(response).to be_success

      expect(json_data['title']).to eq(new_title)
      expect(json_data['draft']).to eq(false)
      new_post = Post.find(existing_post.id)
      expect(new_post.title).to eq(new_title)
      expect(new_post.draft).to eq(false)
    end

    it 'should set the draft to false when draft=false is passed' do
      existing_post.update(draft:true)

      put "/posts/#{existing_post.id}", api_key: api_key_for_user(turd_ferg),
                                        format: :json,
                                        post: { title: new_title, draft: false }

      expect(response).to be_success

      expect(json_data['draft']).to eq(false)
      new_post = Post.find(existing_post.id)
      expect(new_post.draft).to eq(false)
    end

    context 'current_user is NOT Post creator' do
      it 'should NOT be authorized' do
        put "/posts/#{existing_post.id}", api_key: api_key_for_user(FactoryGirl.create(:user)),
                                          format: :json,
                                          post: { title: new_title }

        expect(response).to_not be_success
      end
    end
  end

  describe 'DELETE /posts/{:post_id} posts#destroy' do
    let(:existing_post) { FactoryGirl.create(:post_with_creator, creator: chef) }

    it 'soft deletes the Post' do
      delete "/posts/#{existing_post.id}", api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(Post.find_by(id: existing_post.id)).to be_nil
    end

    it 'soft deletes the Post\'s FeedItem' do
      delete "/posts/#{existing_post.id}", api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(FeedItem.find_by(subject_id: existing_post.id, subject_type:existing_post.class)).to be_nil
    end

    context 'Morsels in a Post' do
      let(:existing_post) { FactoryGirl.create(:post_with_morsels, creator: chef) }

      it 'soft deletes all of its Morsels' do
        delete "/posts/#{existing_post.id}", api_key: api_key_for_user(chef), format: :json

        expect(response).to be_success
        expect(existing_post.morsels).to be_empty
      end
    end

    context 'current_user is NOT Post creator' do
      it 'should NOT be authorized' do
        delete "/posts/#{existing_post.id}", api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /posts/drafts posts#drafts' do
    let(:posts_count) { 3 }
    let(:draft_posts_count) { rand(3..6) }

    before do
      posts_count.times { FactoryGirl.create(:post_with_morsels, morsels_count: morsels_count) }
      draft_posts_count.times { FactoryGirl.create(:draft_post_with_morsels, creator: turd_ferg) }
    end

    it 'returns the authenticated User\'s Post Drafts' do
      get '/posts/drafts', api_key: api_key_for_user(turd_ferg),
                           format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(draft_posts_count)

      first_post = json_data.first

      expect(first_post['draft']).to be_true

      expect(first_post['creator']).to_not be_nil
    end

    it 'returns post_id, sort_order, and url for each Morsel' do
      get '/posts', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      first_morsel = json_data.first['morsels'].first
      expect(first_morsel['post_id']).to_not be_nil
      expect(first_morsel['sort_order']).to_not be_nil
      expect(first_morsel['url']).to_not be_nil
    end

    context 'pagination' do
      before do
        30.times { FactoryGirl.create(:draft_post_with_morsels, creator: turd_ferg) }
      end

      describe 'max_id' do
        it 'returns results up to and including max_id' do
          expected_count = rand(3..6)
          max_id = Post.where(creator_id: turd_ferg.id, draft: true).order('id ASC').first.id + expected_count - 1
          get '/posts/drafts', api_key: api_key_for_user(turd_ferg),
                               max_id: max_id,
                               format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.first['id']).to eq(max_id)
        end
      end

      describe 'since_id' do
        it 'returns results since since_id' do
          expected_count = rand(3..6)
          since_id = Post.last.id - expected_count
          get '/posts/drafts', api_key: api_key_for_user(turd_ferg),
                               since_id: since_id,
                               format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.last['id']).to eq(since_id + 1)
        end
      end

      describe 'count' do
        it 'defaults to 20' do
          get '/posts/drafts', api_key: api_key_for_user(turd_ferg),
                               format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(20)
        end

        it 'limits the result' do
          expected_count = rand(3..6)
          get '/posts/drafts', api_key: api_key_for_user(turd_ferg),
                               count: expected_count,
                               format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
        end
      end
    end
  end
end
