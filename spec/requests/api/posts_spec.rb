require 'spec_helper'

describe 'Posts API' do
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
  let(:morsels_count) { 4 }

  describe 'GET /posts posts#index' do
    let(:posts_count) { 3 }

    before do
      posts_count.times { FactoryGirl.create(:post_with_morsels_and_creator, morsels_count: morsels_count) }
    end

    it 'returns a list of Posts' do
      get '/posts', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(posts_count)

      expect(json_data.first['morsels'].count).to eq(morsels_count)
    end

    it 'returns liked for each Morsel' do
      get '/posts', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      first_morsel = json_data.first['morsels'].first
      expect(first_morsel['liked']).to_not be_nil
    end

    it 'should be public' do
      get '/posts', format: :json

      expect(response).to be_success
    end

    context 'has drafts' do
      before do
        rand(3..6).times { FactoryGirl.create(:draft_post_with_morsels_and_creator) }
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

    context 'performance', performance: true do
      before do
        require 'benchmark'
      end

      it 'should take time' do
        Benchmark.realtime { get('/posts', api_key: api_key_for_user(turd_ferg), format: :json) }.should < 0.5
      end

      context 'twenty Posts' do
        before do
          20.times { FactoryGirl.create(:post_with_morsels_and_creator) }
        end

        it 'should take more time' do
          Benchmark.realtime {
            get '/posts', api_key: api_key_for_user(turd_ferg), format: :json
          }.should < 1.5
        end
      end
    end

    context 'user_id included in parameters' do
      let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator) }

      it 'returns all Posts for user_id' do
        get '/posts', api_key: api_key_for_user(turd_ferg),
                      user_id_or_username: post_with_morsels_and_creator.creator.id,
                      format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(1)

        creator_id = post_with_morsels_and_creator.creator.id

        json_data.each do |morsel_json|
          expect(morsel_json['creator_id']).to eq(creator_id)
        end
      end

      context 'performance', performance: true do
        before do
          require 'benchmark'
        end

        it 'should take time' do
          Benchmark.realtime { get('/posts', api_key: api_key_for_user(turd_ferg), format: :json) }.should < 0.5
        end

        context 'twenty Posts' do
          before do
            20.times { FactoryGirl.create(:post_with_morsels_and_creator) }
          end

          it 'should take more time' do
            Benchmark.realtime {
              get '/posts', api_key: api_key_for_user(turd_ferg), format: :json
            }.should < 1.25
          end
        end
      end
    end
  end

  describe 'GET /posts posts#show' do
    let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator, morsels_count: morsels_count) }

    it 'returns the Post' do
      get "/posts/#{post_with_morsels_and_creator.id}", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, post_with_morsels_and_creator, %w(id title creator_id))
      expect(json_data['slug']).to eq(post_with_morsels_and_creator.cached_slug)

      expect(json_data['morsels'].count).to eq(morsels_count)
    end

    it 'should be public' do
      get "/posts/#{post_with_morsels_and_creator.id}", format: :json

      expect(response).to be_success
    end
  end

  describe 'PUT /posts/{:post_id} posts#update' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator) }
    let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

    it 'updates the Post' do
      put "/posts/#{existing_post.id}", api_key: api_key_for_user(turd_ferg),
                                        format: :json,
                                        post: { title: new_title }

      expect(response).to be_success

      expect(json_data['title']).to eq(new_title)
      expect(Post.find(existing_post.id).title).to eq(new_title)
    end
  end

  describe 'POST /posts/{:post_id}/append posts#append' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator, morsels_count: morsels_count) }
    let(:morsel_with_creator) { FactoryGirl.create(:morsel_with_creator) }

    it 'appends the Morsel to the Post' do
      post "/posts/#{existing_post.id}/append", api_key: api_key_for_user(turd_ferg),
                                                format: :json,
                                                morsel_id: morsel_with_creator.id

      expect(response).to be_success

      expect(json_data['id']).to eq(existing_post.id)

      expect(existing_post.morsels).to include(morsel_with_creator)

      expect(json_data['morsels'].count).to eq(morsels_count + 1)
    end

    context 'relationship already exists' do
      let(:morsel_in_existing_post) { existing_post.morsels.first }

      it 'returns an error' do
        post "/posts/#{existing_post.id}/append", api_key: api_key_for_user(turd_ferg),
                                                  format: :json,
                                                  morsel_id: morsel_in_existing_post.id

        expect(response).to_not be_success
        expect(response.status).to eq(400)

        expect(json_data).to be_nil
        expect(json_errors['relationship'].first).to eq('already exists')
      end
    end

    context 'sort_order included in parameters' do
      let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator) }

      it 'changes the sort_order' do
        post "/posts/#{existing_post.id}/append", api_key: api_key_for_user(turd_ferg),
                                                  format: :json,
                                                  morsel_id: morsel_with_creator.id,
                                                  sort_order: 1

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        expect(existing_post.morsel_ids.first).to eq(json_data['morsels'].first['id'])
      end
    end
  end

  describe 'DELETE posts/{:post_id}/append posts#unappend' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator) }
    let(:morsel_in_existing_post) { existing_post.morsels.first }

    it 'unappends the Morsel from the Post' do
      delete "/posts/#{existing_post.id}/append", api_key: api_key_for_user(turd_ferg),
                                                  format: :json,
                                                  morsel_id: morsel_in_existing_post.id

      expect(response).to be_success

      expect(existing_post.morsels).to_not include(morsel_in_existing_post)
    end

    context 'relationship not found' do
      let(:morsel_with_creator) { FactoryGirl.create(:morsel_with_creator) }
      it 'returns an error' do
        delete "/posts/#{existing_post.id}/append", api_key: api_key_for_user(turd_ferg),
                                                    format: :json,
                                                    morsel_id: morsel_with_creator.id

        expect(response).to_not be_success
        expect(response.status).to eq(404)

        expect(json_data).to be_nil
        expect(json_errors['relationship'].first).to eq('not found')
      end
    end
  end

  describe 'GET /posts/drafts posts#drafts' do
    let(:posts_count) { 3 }
    let(:draft_posts_count) { rand(3..6) }

    before do
      posts_count.times { FactoryGirl.create(:post_with_morsels_and_creator, morsels_count: morsels_count) }
      draft_posts_count.times { FactoryGirl.create(:draft_post_with_morsels_and_creator, creator: turd_ferg) }
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

    context 'pagination' do
      before do
        30.times { FactoryGirl.create(:draft_post_with_morsels_and_creator, creator: turd_ferg) }
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
