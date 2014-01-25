require 'spec_helper'

describe 'Posts API' do
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

  describe 'GET /posts posts#index' do
    before do
      4.times { FactoryGirl.create(:post_with_morsels_and_creator) }
    end

    it 'returns a list of Posts' do
      get '/posts', api_key: turd_ferg.id, format: :json

      expect(response).to be_success

      expect(json.count).to eq(4)
    end

    context 'user_id included in parameters' do
      let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator) }

      it 'returns all Posts for user_id' do
        get '/posts', api_key: turd_ferg.id,
                      user_id: post_with_morsels_and_creator.creator.id,
                      format: :json

        expect(response).to be_success

        expect(json.count).to eq(1)

        creator_id = post_with_morsels_and_creator.creator.id

        json.each do |morsel_json|
          expect(morsel_json['creator_id']).to eq(creator_id)
        end
      end
    end
  end

  describe 'GET /posts posts#show' do
    let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator) }

    it 'returns the Post' do
      get "/posts/#{post_with_morsels_and_creator.id}", api_key: turd_ferg.id, format: :json

      expect(response).to be_success

      expect_json_keys(json, post_with_morsels_and_creator, %w(id title creator_id))
      expect(json['slug']).to eq(post_with_morsels_and_creator.cached_slug)
    end
  end

  describe 'PUT /posts/{:post_id} posts#update' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator) }
    let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

    it 'updates the Post' do
      put "/posts/#{existing_post.id}", api_key: turd_ferg.id,
                                        format: :json,
                                        post: { title: new_title }

      expect(response).to be_success

      expect(json['title']).to eq(new_title)
      expect(Post.find(existing_post.id).title).to eq(new_title)
    end
  end

  describe 'POST /posts/{:post_id}/append posts#append' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator) }
    let(:morsel) { FactoryGirl.create(:morsel) }

    it 'appends the Morsel to the Post' do
      post "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                format: :json,
                                                morsel_id: morsel.id

      expect(response).to be_success

      expect(json['id']).to eq(existing_post.id)

      expect(existing_post.morsels).to include(morsel)
    end

    context 'relationship already exists' do
      let(:morsel_in_existing_post) { existing_post.morsels.first }

      it 'returns an error' do
        post "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                  format: :json,
                                                  morsel_id: morsel_in_existing_post.id

        expect(response).to_not be_success

        expect(json['errors'].first['msg']).to eq('Relationship already exists')
      end
    end

    context 'sort_order included in parameters' do
      let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator) }

      it 'changes the sort_order' do
        post "/posts/#{existing_post.id}/append", api_key: turd_ferg.id,
                                                  format: :json,
                                                  morsel_id: morsel.id,
                                                  sort_order: 1

        expect(response).to be_success

        expect(json['id']).to_not be_nil

        expect(existing_post.morsel_ids.first).to eq(json['morsels'].first['id'])
      end
    end
  end

  describe 'DELETE posts/{:post_id}/append posts#unappend' do
    let(:existing_post) { FactoryGirl.create(:post_with_morsels_and_creator) }
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

        expect(json['errors'].first['msg']).to eq('Relationship not found')
      end
    end
  end
end
