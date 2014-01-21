require 'spec_helper'

describe 'Morsels API' do
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

  describe 'GET /api/morsels morsels#index' do
    before do
      4.times { FactoryGirl.create(:morsel_with_creator) }
    end

    it 'returns a list of Morsels' do
      get '/api/morsels', api_key: turd_ferg.id, format: :json

      expect(response).to be_success

      expect(json.count).to eq(4)
    end

    context 'user_id included in parameters' do
      let(:post_with_morsels_and_creator) { FactoryGirl.create(:post_with_morsels_and_creator) }

      it 'returns all Morsels for user_id' do
        get '/api/morsels', api_key: turd_ferg.id, user_id: post_with_morsels_and_creator.creator.id, format: :json

        expect(response).to be_success

        expect(json.count).to eq(3)

        creator_id = post_with_morsels_and_creator.creator.id

        json.each do |morsel_json|
          expect(morsel_json['creator_id']).to eq(creator_id)
        end
      end
    end
  end

  describe 'POST /api/morsels morsels#create' do
    let(:existing_post) { FactoryGirl.create(:post) }

    it 'creates a Morsel' do
      post '/api/morsels',  api_key: turd_ferg.id,
                            format: :json,
                            morsel: {
                              description: 'It\'s not a toomarh!',
                              photo: Rack::Test::UploadedFile.new(
                                File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))) }

      expect(response).to be_success

      expect(json['id']).to_not be_nil

      new_morsel = Morsel.find json['id']
      expect_json_keys(json, new_morsel, %w(id description creator_id))
      expect(json['photo_url']).to eq(new_morsel.photo_url)

      expect(new_morsel.posts).to_not include(existing_post)
    end

    context 'post_id included in parameters' do
      it 'appends the Morsel to the Post' do
        post '/api/morsels',  api_key: turd_ferg.id,
                              format: :json,
                              morsel: { description: 'On Top of the World.' },
                              post_id: existing_post.id

        expect(response).to be_success

        expect(json['id']).to_not be_nil

        new_morsel = Morsel.find json['id']
        expect(new_morsel.posts).to include(existing_post)
      end

      context 'sort_order included in parameters' do
        let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }

        it 'changes the sort_order' do
          post '/api/morsels',  api_key: turd_ferg.id,
                                format: :json,
                                morsel: { description: 'Parabol.' },
                                post_id: post_with_morsels.id,
                                sort_order: 1

          expect(response).to be_success

          expect(json['id']).to_not be_nil

          expect(post_with_morsels.morsel_ids.first).to eq(json['id'])
        end
      end
    end

    context 'post_title included in parameters' do
      let(:expected_title) { 'Symphony of Destruction' }
      it 'changes the post_title' do
        post '/api/morsels',  api_key: turd_ferg.id,
                              format: :json,
                              morsel: { description: 'Explooooooooooooooodes-aaah' },
                              post_title: expected_title

        expect(response).to be_success

        expect(json['id']).to_not be_nil

        new_morsel = Morsel.find json['id']
        expect(new_morsel.posts.first.title).to eq(expected_title)
      end
    end

    context 'post_to_twitter included in parameters' do
      let(:user_with_twitter_authorization) { FactoryGirl.create(:user_with_twitter_authorization) }
      let(:expected_tweet_url) { "https://twitter.com/#{user_with_twitter_authorization.username}/status/12345" }

      it 'posts a Tweet' do
        client = double('Twitter::REST::Client')
        tweet = double('Twitter::Tweet')
        tweet.stub(:url).and_return(expected_tweet_url)

        Twitter::Client.stub(:new).and_return(client)
        client.stub(:update).and_return(tweet)

        post '/api/morsels',  api_key: user_with_twitter_authorization.id,
                              format: :json,
                              morsel: { description: 'D.A.N.C.E.' },
                              post_to_twitter: true

        expect(response).to be_success

        expect(json['id']).to_not be_nil

        expect(json['tweet_url']).to eq(expected_tweet_url)
      end
    end
  end

  describe 'GET /api/morsels morsels#show' do
    let(:morsel) { FactoryGirl.create(:morsel) }

    it 'returns the Morsel' do
      get "/api/morsels/#{morsel.id}", api_key: turd_ferg.id, format: :json

      expect(response).to be_success

      expect_json_keys(json, morsel, %w(id description creator_id))
      expect(json['liked']).to be_false
      expect(json['photo_url']).to eq(morsel.photo_url)
    end
  end

  describe 'PUT /api/morsels/{:morsel_id} morsels#update' do
    let(:existing_morsel) { FactoryGirl.create(:morsel) }
    let(:new_description) { 'The proof is in the puddin' }

    it 'updates the Morsel' do
      put "/api/morsels/#{existing_morsel.id}", api_key: turd_ferg.id,
                                                format: :json,
                                                morsel: { description: new_description }

      expect(response).to be_success

      expect(json['description']).to eq(new_description)
      expect(Morsel.find(existing_morsel.id).description).to eq(new_description)
    end

    context 'post_id and sort_order included in parameters' do
      let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
      let(:last_morsel) { post_with_morsels.morsels.last }

      it 'changes the sort_order' do
        put "/api/morsels/#{last_morsel.id}", api_key: turd_ferg.id,
                                              format: :json,
                                              morsel: { description: 'Just like a bus route.' },
                                              post_id: post_with_morsels.id,
                                              sort_order: 1

        expect(response).to be_success

        expect(json['id']).to_not be_nil

        expect(post_with_morsels.morsel_ids.first).to eq(json['id'])
      end
    end
  end

  describe 'DELETE /api/morsels/{:morsel_id} morsels#destroy' do
    let(:existing_morsel) { FactoryGirl.create(:morsel) }

    it 'soft deletes the Morsel' do
      delete "/api/morsels/#{existing_morsel.id}", api_key: turd_ferg.id, format: :json

      expect(response).to be_success
      expect(Morsel.where(id: existing_morsel.id)).to be_empty
    end
  end
end
