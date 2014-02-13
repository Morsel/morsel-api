require 'spec_helper'

describe 'Morsels API' do
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

  describe 'POST /morsels morsels#create' do
    let(:existing_post) { FactoryGirl.create(:post) }

    it 'creates a Morsel' do
      post '/morsels',  api_key: api_key_for_user(turd_ferg),
                        format: :json,
                        morsel: {
                          description: 'It\'s not a toomarh!',
                          photo: Rack::Test::UploadedFile.new(
                            File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))) }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_morsel = Morsel.find json_data['id']
      expect_json_keys(json_data, new_morsel, %w(id description creator_id))
      expect(json_data['photos']).to_not be_nil

      expect(new_morsel.posts).to_not include(existing_post)
    end

    context 'post_id included in parameters' do
      it 'appends the Morsel to the Post' do
        post '/morsels',  api_key: api_key_for_user(turd_ferg),
                          format: :json,
                          morsel: { description: 'On Top of the World.' },
                          post_id: existing_post.id

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        new_morsel = Morsel.find json_data['id']
        expect(new_morsel.posts).to include(existing_post)
      end

      context 'sort_order included in parameters' do
        let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }

        it 'changes the sort_order' do
          post '/morsels',  api_key: api_key_for_user(turd_ferg),
                            format: :json,
                            morsel: { description: 'Parabol.' },
                            post_id: post_with_morsels.id,
                            sort_order: 1

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          expect(post_with_morsels.morsel_ids.first).to eq(json_data['id'])
        end
      end
    end

    context 'post_title included in parameters' do
      let(:expected_title) { 'Symphony of Destruction' }
      it 'changes the post_title' do
        post '/morsels',  api_key: api_key_for_user(turd_ferg),
                          format: :json,
                          morsel: { description: 'Explooooooooooooooodes-aaah' },
                          post_title: expected_title

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        new_morsel = Morsel.find json_data['id']
        expect(new_morsel.posts.first.title).to eq(expected_title)
      end
    end

    context 'post_to_facebook included in parameters' do
      let(:user_with_facebook_authorization) { FactoryGirl.create(:user_with_facebook_authorization) }

      it 'posts to Facebook' do
        dummy_name = 'Facebook User'

        facebook_user = double('Hash')
        facebook_user.stub(:[]).with('id').and_return('12345_67890')
        facebook_user.stub(:[]).with('name').and_return(dummy_name)

        client = double('Koala::Facebook::API')

        Koala::Facebook::API.stub(:new).and_return(client)

        client.stub(:put_connections).and_return('id' => '12345_67890')

        expect {
          post '/morsels',  api_key: api_key_for_user(user_with_facebook_authorization),
                            format: :json,
                            morsel: { description: 'The Fresh Prince of Bel Air' },
                            post_to_facebook: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

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

        expect {
          post '/morsels',  api_key: api_key_for_user(user_with_twitter_authorization),
                            format: :json,
                            morsel: { description: 'D.A.N.C.E.' },
                            post_to_twitter: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
      end
    end

    context 'draft set to true' do
      it 'should return draft set to true' do
        post '/morsels',  api_key: api_key_for_user(turd_ferg),
                          format: :json,
                          morsel: { description: 'Mnemic', draft: true }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
        expect(json_data['draft']).to be_true

        new_morsel = Morsel.find json_data['id']
        expect(new_morsel.draft).to be_true
      end
    end
  end

  describe 'GET /morsels morsels#show' do
    let(:morsel) { FactoryGirl.create(:morsel) }

    it 'returns the Morsel' do
      get "/morsels/#{morsel.id}", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, morsel, %w(id description creator_id))
      expect(json_data['liked']).to be_false
      expect(json_data['photos']).to_not be_nil
      expect(json_data['draft']).to be_nil
    end

    context 'has a photo' do
      before do
        morsel.photo = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
        morsel.save
      end

      it 'returns the User with the appropriate image sizes' do
        get "/morsels/#{morsel.id}", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        photos = json_data['photos']
        expect(photos['_640x640']).to_not be_nil
        expect(photos['_640x428']).to_not be_nil
        expect(photos['_320x214']).to_not be_nil
        expect(photos['_208x208']).to_not be_nil
        expect(photos['_104x104']).to_not be_nil
      end
    end

    context 'has Comments' do
      before do
        2.times { FactoryGirl.create(:comment, morsel: morsel) }
      end

      it 'returns the Morsel with Comments' do
        get "/morsels/#{morsel.id}", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        expect_json_keys(json_data, morsel, %w(id description creator_id))
        expect(json_data['liked']).to be_false

        expect(json_data['comments']).to_not be_empty
      end
    end
  end

  describe 'PUT /morsels/{:morsel_id} morsels#update' do
    let(:existing_morsel) { FactoryGirl.create(:morsel) }
    let(:new_description) { 'The proof is in the puddin' }

    it 'updates the Morsel' do
      put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(turd_ferg),
                                            format: :json,
                                            morsel: { description: new_description }

      expect(response).to be_success

      expect(json_data['description']).to eq(new_description)
      expect(Morsel.find(existing_morsel.id).description).to eq(new_description)
    end

    context 'post_id and sort_order included in parameters' do
      let(:post_with_morsels_and_creator_and_draft) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }
      let(:last_morsel) { post_with_morsels_and_creator_and_draft.morsels.last }

      context 'Morsel belongs to the Post' do
        it 'changes the sort_order' do
          put "/morsels/#{last_morsel.id}", api_key: api_key_for_user(turd_ferg),
                                            format: :json,
                                            morsel: { description: 'Just like a bus route.' },
                                            post_id: post_with_morsels_and_creator_and_draft.id,
                                            sort_order: 1

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          expect(post_with_morsels_and_creator_and_draft.morsel_ids.first).to eq(json_data['id'])
        end
      end

      context 'Morsel does NOT belong to the Post' do
        let(:different_post) { FactoryGirl.create(:post_with_morsels_and_creator_and_draft) }
        it 'changes the Morsel\'s Post and removes it from the previous one' do
          put "/morsels/#{last_morsel.id}", api_key: api_key_for_user(turd_ferg),
                                            format: :json,
                                            morsel: { description: 'I should be on a different Post.' },
                                            post_id: post_with_morsels_and_creator_and_draft.id,
                                            new_post_id: different_post.id

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          expect(different_post.morsel_ids.last).to eq(json_data['id'])

          # Morsel should no longer be associated with the original Post
          expect(post_with_morsels_and_creator_and_draft.morsels).to_not include(last_morsel)
        end
      end
    end
  end

  describe 'DELETE /morsels/{:morsel_id} morsels#destroy' do
    let(:existing_morsel) { FactoryGirl.create(:morsel) }

    it 'soft deletes the Morsel' do
      delete "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      expect(Morsel.where(id: existing_morsel.id)).to be_empty
    end
  end

  describe 'GET /morsels/{:morsel_id}/comments comments#index' do
    let(:morsel_with_creator_and_comments) { FactoryGirl.create(:morsel_with_creator_and_comments) }

    it 'returns a list of Comments for the Morsel' do
      get "/morsels/#{morsel_with_creator_and_comments.id}/comments", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(2)
    end
  end

  describe 'POST /morsels/{:morsel_id}/comments comments#create' do
    let(:existing_morsel) { FactoryGirl.create(:morsel) }

    it 'creates a Comment for the Morsel' do
      post "/morsels/#{existing_morsel.id}/comments", api_key: api_key_for_user(turd_ferg),
                                                      format: :json,
                                                      comment: {
                                                        description: 'Drop it like it\'s hot.' }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_comment = Comment.find(json_data['id'])
      expect_json_keys(json_data, new_comment, %w(id description))
      expect(json_data['creator_id']).to eq(new_comment.user.id)
      expect(json_data['morsel_id']).to eq(new_comment.morsel.id)
    end
  end

  describe 'DELETE /comments/{:comment_id} comments#destroy' do
    let(:existing_comment) { FactoryGirl.create(:comment) }
    context 'current_user is the Comment creator' do
      before do
        existing_comment.user = turd_ferg
        existing_comment.save
      end

      it 'soft deletes the Comment' do
        delete "/comments/#{existing_comment.id}", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success
        expect(Comment.where(id: existing_comment.id)).to be_empty
      end
    end

    context 'current_user is the Morsel creator' do
      before do
        existing_comment.morsel.creator = turd_ferg
        existing_comment.morsel.save
      end

      it 'soft deletes the Comment' do
        delete "/comments/#{existing_comment.id}", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success
        expect(Comment.where(id: existing_comment.id)).to be_empty
      end
    end

    context 'current_user is not the Comment or Morsel creator' do
      it 'does NOT soft delete the Comment' do
        delete "/comments/#{existing_comment.id}", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to_not be_success
        expect(Comment.where(id: existing_comment.id)).to_not be_empty
      end
    end
  end
end
