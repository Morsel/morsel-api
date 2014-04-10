require 'spec_helper'
describe 'Morsels API' do
  let(:chef) { FactoryGirl.create(:chef) }
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
  let(:items_count) { 4 }

  describe 'GET /morsels morsels#index' do
    let(:morsels_count) { 3 }

    before do
      morsels_count.times { FactoryGirl.create(:morsel_with_items, items_count: items_count) }
    end

    it 'returns a list of Morsels' do
      get '/morsels', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(morsels_count)

      first_morsel = json_data.first

      expect(first_morsel['items'].count).to eq(items_count)
      expect(first_morsel['total_like_count']).to_not be_nil
      expect(first_morsel['total_comment_count']).to_not be_nil
      expect(first_morsel['photos']).to be_nil

      first_item = first_morsel['items'].first
      expect(first_item['like_count']).to_not be_nil
      expect(first_item['comment_count']).to_not be_nil
    end

    it 'returns liked for each Item' do
      get '/morsels', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      first_item = json_data.first['items'].first
      expect(first_item['liked']).to_not be_nil
    end

    it 'returns morsel_id, sort_order, and url for each Item' do
      get '/morsels', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      first_item = json_data.first['items'].first
      expect(first_item['morsel_id']).to_not be_nil
      expect(first_item['sort_order']).to_not be_nil
      expect(first_item['url']).to_not be_nil
    end

    it 'should be public' do
      get '/morsels', format: :json

      expect(response).to be_success
    end

    context 'has drafts' do
      let(:draft_morsels_count) { rand(3..6) }
      before do
        draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items) }
      end

      it 'should NOT include drafts' do
        get '/morsels', api_key: api_key_for_user(turd_ferg),
                      format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(morsels_count)
      end
    end

    context 'pagination' do
      before do
        30.times { FactoryGirl.create(:morsel_with_creator) }
      end

      describe 'max_id' do
        it 'returns results up to and including max_id' do
          expected_count = rand(3..6)
          max_id = Morsel.first.id + expected_count - 1
          get '/morsels', api_key: api_key_for_user(turd_ferg),
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
          since_id = Morsel.last.id - expected_count
          get '/morsels', api_key: api_key_for_user(turd_ferg),
                        since_id: since_id,
                        format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.last['id']).to eq(since_id + 1)
        end
      end

      describe 'count' do
        it 'defaults to 20' do
          get '/morsels', api_key: api_key_for_user(turd_ferg),
                        format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(20)
        end

        it 'limits the result' do
          expected_count = rand(3..6)
          get '/morsels', api_key: api_key_for_user(turd_ferg),
                        count: expected_count,
                        format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
        end
      end
    end

    context 'user_id included in parameters' do
      let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items) }

      it 'returns all Morsels for user_id' do
        get '/morsels', api_key: api_key_for_user(turd_ferg),
                      user_id_or_username: morsel_with_items.creator.id,
                      format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(1)

        creator_id = morsel_with_items.creator.id

        json_data.each do |item_json|
          expect(item_json['creator_id']).to eq(creator_id)
        end
      end
    end
  end

  describe 'POST /morsels morsels#create', sidekiq: :inline do
    let(:expected_title) { 'Bake Sale!' }

    it 'creates a Morsel' do
      post '/morsels',  api_key: api_key_for_user(chef),
                      format: :json,
                      morsel: {
                        title: expected_title
                      }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_morsel = Morsel.find json_data['id']
      expect_json_keys(json_data, new_morsel, %w(id title creator_id))
      expect(json_data['title']).to eq(expected_title)
      expect(json_data['photos']).to be_nil
      expect(new_morsel.draft).to be_true
    end

    context 'draft is set to true' do
      it 'creates a draft Morsel' do
        post '/morsels',  api_key: api_key_for_user(chef),
                        format: :json,
                        morsel: {
                          title: expected_title,
                          draft: true
                        }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        new_morsel = Morsel.find json_data['id']
        expect_json_keys(json_data, new_morsel, %w(id title creator_id))
        expect(json_data['title']).to eq(expected_title)
        expect(new_morsel.draft).to be_true
      end
    end

    context 'primary_item_id is included' do
      let(:some_item) { FactoryGirl.create(:item_with_creator) }
      it 'should fail since a new Morsel has no Items' do
        post '/morsels',  api_key: api_key_for_user(chef),
                        format: :json,
                        morsel: {
                          title: expected_title,
                          primary_item_id: FactoryGirl.create(:item).id
                        }

        expect(response).to_not be_success

        expect(json_errors['primary_item'].first).to eq('does not belong to this Morsel')
      end
    end
  end

  describe 'GET /morsels morsels#show' do
    let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

    it 'returns the Morsel' do
      get "/morsels/#{morsel_with_items.id}", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, morsel_with_items, %w(id title creator_id))
      expect(json_data['slug']).to eq(morsel_with_items.cached_slug)

      expect(json_data['items'].count).to eq(items_count)
    end

    it 'should be public' do
      get "/morsels/#{morsel_with_items.id}", format: :json

      expect(response).to be_success
    end

    context 'has a photo' do
      let(:morsel_with_creator_and_photo) { FactoryGirl.create(:morsel_with_creator_and_photo) }

      it 'returns the Morsel with photos' do
        get "/morsels/#{morsel_with_creator_and_photo.id}", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        expect_json_keys(json_data, morsel_with_creator_and_photo, %w(id title creator_id))
        photos = json_data['photos']
        expect(photos['_400x300']).to_not be_nil
      end
    end
  end

  describe 'PUT /morsels/{:morsel_id} morsels#update' do
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_items, creator: turd_ferg) }
    let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

    it 'updates the Morsel' do
      put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(turd_ferg),
                                        format: :json,
                                        morsel: { title: new_title }

      expect(response).to be_success

      expect(json_data['title']).to eq(new_title)
      expect(json_data['draft']).to eq(false)
      new_morsel = Morsel.find(existing_morsel.id)
      expect(new_morsel.title).to eq(new_title)
      expect(new_morsel.draft).to eq(false)
    end

    it 'should set the draft to false when draft=false is passed' do
      existing_morsel.update(draft:true)

      put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(turd_ferg),
                                        format: :json,
                                        morsel: { title: new_title, draft: false }

      expect(response).to be_success

      expect(json_data['draft']).to eq(false)
      new_morsel = Morsel.find(existing_morsel.id)
      expect(new_morsel.draft).to eq(false)
    end

    context 'primary_item_id is included' do
      let(:some_item) { FactoryGirl.create(:item_with_creator, morsel: existing_morsel) }
      it 'updates the primary_item_id' do
        put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(turd_ferg),
                                          format: :json,
                                          morsel: {
                                            title: new_title,
                                            primary_item_id: some_item.id
                                          }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        new_morsel = Morsel.find json_data['id']
        expect_json_keys(json_data, new_morsel, %w(id title creator_id))
        expect(json_data['primary_item_id']).to eq(some_item.id)
        expect(new_morsel.primary_item_id).to eq(some_item.id)
      end

      it 'should fail if primary_item_id is not one of the Morsel\'s Items' do
        put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(turd_ferg),
                                          format: :json,
                                          morsel: {
                                            title: new_title,
                                            primary_item_id: FactoryGirl.create(:item).id
                                          }

        expect(response).to_not be_success

        expect(json_errors['primary_item'].first).to eq('does not belong to this Morsel')
      end
    end

    context 'current_user is NOT Morsel creator' do
      it 'should NOT be authorized' do
        put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(FactoryGirl.create(:user)),
                                          format: :json,
                                          morsel: { title: new_title }

        expect(response).to_not be_success
      end
    end

  end

  describe 'DELETE /morsels/{:morsel_id} morsels#destroy' do
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_creator, creator: chef) }

    it 'soft deletes the Morsel' do
      delete "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(Morsel.find_by(id: existing_morsel.id)).to be_nil
    end

    it 'soft deletes the Morsel\'s FeedItem' do
      delete "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(FeedItem.find_by(subject_id: existing_morsel.id, subject_type:existing_morsel.class)).to be_nil
    end

    context 'Items in a Morsel' do
      let(:existing_morsel) { FactoryGirl.create(:morsel_with_items, creator: chef) }

      it 'soft deletes all of its Items' do
        delete "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(chef), format: :json

        expect(response).to be_success
        expect(existing_morsel.items).to be_empty
      end
    end

    context 'current_user is NOT Morsel creator' do
      it 'should NOT be authorized' do
        delete "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'POST /morsels/{:morsel_id}/publish morsels#publish' do
    let(:existing_draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: chef) }
    it 'should publish the Morsel by setting draft to false and setting a published_at DateTime' do
      post "/morsels/#{existing_draft_morsel.id}/publish",  api_key: api_key_for_user(chef),
                                                      format: :json

      expect(response).to be_success

      expect(json_data['draft']).to eq(false)
      new_morsel = Morsel.find(existing_draft_morsel.id)
      expect(new_morsel.draft).to eq(false)
    end

    context 'post_to_facebook included in parameters' do
      let(:chef_with_facebook_authorization) { FactoryGirl.create(:chef_with_facebook_authorization) }
      let(:existing_draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: chef_with_facebook_authorization) }

      it 'posts to Facebook' do
        dummy_name = 'Facebook User'

        facebook_user = double('Hash')
        facebook_user.stub(:[]).with('id').and_return('12345_67890')
        facebook_user.stub(:[]).with('name').and_return(dummy_name)

        client = double('Koala::Facebook::API')

        Koala::Facebook::API.stub(:new).and_return(client)

        client.stub(:put_connections).and_return('id' => '12345_67890')

        expect {
          post "/morsels/#{existing_draft_morsel.id}/publish",  api_key: api_key_for_user(chef_with_facebook_authorization),
                                                                format: :json,
                                                                post_to_facebook: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
      end
    end

    context 'post_to_twitter included in parameters' do
      let(:chef_with_twitter_authorization) { FactoryGirl.create(:chef_with_twitter_authorization) }
      let(:existing_draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: chef_with_twitter_authorization) }

      let(:expected_tweet_url) { "https://twitter.com/#{chef_with_twitter_authorization.username}/status/12345" }

      it 'posts a Tweet' do
        client = double('Twitter::REST::Client')
        tweet = double('Twitter::Tweet')
        tweet.stub(:url).and_return(expected_tweet_url)

        Twitter::Client.stub(:new).and_return(client)
        client.stub(:update).and_return(tweet)

        expect {
          post "/morsels/#{existing_draft_morsel.id}/publish",  api_key: api_key_for_user(chef_with_twitter_authorization),
                                                                format: :json,
                                                                post_to_twitter: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
      end
    end
  end

  describe 'GET /morsels/drafts morsels#drafts' do
    let(:morsels_count) { 3 }
    let(:draft_morsels_count) { rand(3..6) }

    before do
      morsels_count.times { FactoryGirl.create(:morsel_with_items, items_count: items_count) }
      draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: turd_ferg) }
    end

    it 'returns the authenticated User\'s Morsel Drafts' do
      get '/morsels/drafts', api_key: api_key_for_user(turd_ferg),
                           format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(draft_morsels_count)

      first_morsel = json_data.first

      expect(first_morsel['draft']).to be_true

      expect(first_morsel['creator']).to_not be_nil
    end

    it 'returns morsel_id, sort_order, and url for each Item' do
      get '/morsels', api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success
      first_item = json_data.first['items'].first
      expect(first_item['morsel_id']).to_not be_nil
      expect(first_item['sort_order']).to_not be_nil
      expect(first_item['url']).to_not be_nil
    end

    context 'pagination' do
      before do
        30.times { FactoryGirl.create(:draft_morsel_with_items, creator: turd_ferg) }
      end

      describe 'max_id' do
        it 'returns results up to and including max_id' do
          expected_count = rand(3..6)
          max_id = Morsel.where(creator_id: turd_ferg.id, draft: true).order('id ASC').first.id + expected_count - 1
          get '/morsels/drafts', api_key: api_key_for_user(turd_ferg),
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
          since_id = Morsel.last.id - expected_count
          get '/morsels/drafts', api_key: api_key_for_user(turd_ferg),
                               since_id: since_id,
                               format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.last['id']).to eq(since_id + 1)
        end
      end

      describe 'count' do
        it 'defaults to 20' do
          get '/morsels/drafts', api_key: api_key_for_user(turd_ferg),
                               format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(20)
        end

        it 'limits the result' do
          expected_count = rand(3..6)
          get '/morsels/drafts', api_key: api_key_for_user(turd_ferg),
                               count: expected_count,
                               format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
        end
      end
    end
  end
end
