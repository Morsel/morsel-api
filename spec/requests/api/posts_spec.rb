require 'spec_helper'

describe 'Posts API' do
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

  describe 'GET /posts posts#index' do
    before do
      4.times { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }
    end

    it 'returns a list of Posts' do
      get '/posts', api_key: turd_ferg.id, format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(4)

      expect(json_data.first['morsels'].count).to eq(3)
    end

    context 'user_id included in parameters' do
      let(:post_with_morsels_and_creator_and_draft) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }

      it 'returns all Posts for user_id' do
        get '/posts', api_key: turd_ferg.id,
                      user_id: post_with_morsels_and_creator_and_draft.creator.id,
                      format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(1)

        creator_id = post_with_morsels_and_creator_and_draft.creator.id

        json_data.each do |morsel_json|
          expect(morsel_json['creator_id']).to eq(creator_id)
        end
      end
    end

    context 'include_drafts=true included in parameters' do
      it 'returns all Posts including Morsel drafts' do
        get '/posts', api_key: turd_ferg.id,
                      format: :json,
                      include_drafts: true

        expect(response).to be_success

        expect(json_data.count).to eq(4)

        expect(json_data.first['morsels'].count).to eq(4)
      end
    end
  end

  describe 'GET /posts posts#show' do
    let(:post_with_morsels_and_creator_and_draft) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }

    it 'returns the Post' do
      get "/posts/#{post_with_morsels_and_creator_and_draft.id}", api_key: turd_ferg.id, format: :json

      expect(response).to be_success

      expect_json_keys(json_data, post_with_morsels_and_creator_and_draft, %w(id title creator_id))
      expect(json_data['slug']).to eq(post_with_morsels_and_creator_and_draft.cached_slug)

      expect(json_data['morsels'].count).to eq(3)
    end

    context 'include_drafts=true included in parameters' do
      let(:post_with_morsels_and_creator_and_draft) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }
      it 'returns the Post including Morsel drafts' do
        get "/posts/#{post_with_morsels_and_creator_and_draft.id}", api_key: turd_ferg.id,
                                                          format: :json,
                                                          include_drafts: true

        expect(response).to be_success

        expect_json_keys(json_data, post_with_morsels_and_creator_and_draft, %w(id title creator_id))
        expect(json_data['slug']).to eq(post_with_morsels_and_creator_and_draft.cached_slug)
        expect(json_data['morsels'].count).to eq(4)
      end
    end
  end

  describe 'PUT /posts/{:post_id} posts#update' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }
    let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

    it 'updates the Post' do
      put "/posts/#{existing_post.id}", api_key: turd_ferg.id,
                                        format: :json,
                                        post: { title: new_title }

      expect(response).to be_success

      expect(json_data['title']).to eq(new_title)
      expect(Post.find(existing_post.id).title).to eq(new_title)
    end
  end

  describe 'POST /posts/{:post_id}/append posts#append' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }
    let(:morsel) { FactoryGirl.create(:morsel) }

    it 'appends the Morsel to the Post' do
      post "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                format: :json,
                                                morsel_id: morsel.id

      expect(response).to be_success

      expect(json_data['id']).to eq(existing_post.id)

      expect(existing_post.morsels).to include(morsel)

      expect(json_data['morsels'].count).to eq(4)
    end

    context 'relationship already exists' do
      let(:morsel_in_existing_post) { existing_post.morsels.first }

      it 'returns an error' do
        post "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                  format: :json,
                                                  morsel_id: morsel_in_existing_post.id

        expect(response).to_not be_success
        expect(response.status).to eq(400)

        expect(json_data).to be_nil
        expect(json_errors['relationship'].first).to eq('already exists')
      end
    end

    context 'sort_order included in parameters' do
      let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }

      it 'changes the sort_order' do
        post "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                  format: :json,
                                                  morsel_id: morsel.id,
                                                  sort_order: 1

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        expect(existing_post.morsel_ids.first).to eq(json_data['morsels'].first['id'])
      end
    end

    context 'include_drafts=true included in parameters' do
      it 'appends the Morsel to the Post and includes drafts in the response' do
        post "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                  format: :json,
                                                  include_drafts: true,
                                                  morsel_id: morsel.id

        expect(response).to be_success

        expect(json_data['id']).to eq(existing_post.id)

        expect(existing_post.morsels).to include(morsel)

        expect(json_data['morsels'].count).to eq(5)
      end
    end
  end

  describe 'DELETE posts/{:post_id}/append posts#unappend' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }
    let(:morsel_in_existing_post) { existing_post.morsels.first }

    it 'unappends the Morsel from the Post' do
      delete "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                  format: :json,
                                                  morsel_id: morsel_in_existing_post.id

      expect(response).to be_success

      expect(existing_post.morsels).to_not include(morsel_in_existing_post)
    end

    context 'relationship not found' do
      let(:morsel) { FactoryGirl.create(:morsel) }
      it 'returns an error' do
        delete "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                    format: :json,
                                                    morsel_id: morsel.id

        expect(response).to_not be_success
        expect(response.status).to eq(404)

        expect(json_data).to be_nil
        expect(json_errors['relationship'].first).to eq('not found')
      end
    end
  end
end
