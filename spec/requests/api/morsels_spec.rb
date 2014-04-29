require 'spec_helper'
describe 'Morsels API' do
  let(:chef) { FactoryGirl.create(:chef) }
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
  let(:items_count) { 4 }

  describe 'POST /morsels morsels#create', sidekiq: :inline do
    let(:endpoint) { '/morsels' }
    let(:expected_title) { 'Bake Sale!' }

    it 'creates a Morsel' do
      post endpoint,  api_key: api_key_for_user(chef),
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
        post endpoint,  api_key: api_key_for_user(chef),
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
        post endpoint,  api_key: api_key_for_user(chef),
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
    let(:endpoint) { "/morsels/#{morsel_with_items.id}" }
    let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

    it 'returns the Morsel' do
      get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, morsel_with_items, %w(id title creator_id))
      expect(json_data['slug']).to eq(morsel_with_items.cached_slug)

      expect(json_data['items'].count).to eq(items_count)
    end

    it 'should be public' do
      get endpoint, format: :json

      expect(response).to be_success
    end

    context 'has a photo' do
      let(:endpoint) { "/morsels/#{morsel_with_creator_and_photo.id}" }
      let(:morsel_with_creator_and_photo) { FactoryGirl.create(:morsel_with_creator_and_photo) }

      it 'returns the Morsel with photos' do
        get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        expect_json_keys(json_data, morsel_with_creator_and_photo, %w(id title creator_id))
        photos = json_data['photos']
        expect(photos['_800x600']).to_not be_nil
      end
    end
  end

  describe 'PUT /morsels/{:morsel_id} morsels#update' do
    let(:endpoint) { "/morsels/#{existing_morsel.id}" }
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_items, creator: turd_ferg) }
    let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

    it 'updates the Morsel' do
      put endpoint, api_key: api_key_for_user(turd_ferg),
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

      put endpoint, api_key: api_key_for_user(turd_ferg),
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
        put endpoint, api_key: api_key_for_user(turd_ferg),
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
        put endpoint, api_key: api_key_for_user(turd_ferg),
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
        put endpoint, api_key: api_key_for_user(FactoryGirl.create(:user)),
                      format: :json,
                      morsel: { title: new_title }

        expect(response).to_not be_success
      end
    end

  end

  describe 'DELETE /morsels/{:morsel_id} morsels#destroy' do
    let(:endpoint) { "/morsels/#{existing_morsel.id}" }
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_creator, creator: chef) }

    it 'soft deletes the Morsel' do
      delete endpoint, api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(Morsel.find_by(id: existing_morsel.id)).to be_nil
    end

    it 'soft deletes the Morsel\'s FeedItem' do
      delete endpoint, api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(FeedItem.find_by(subject_id: existing_morsel.id, subject_type:existing_morsel.class)).to be_nil
    end

    context 'Items in a Morsel' do
      let(:existing_morsel) { FactoryGirl.create(:morsel_with_items, creator: chef) }

      it 'soft deletes all of its Items' do
        delete endpoint, api_key: api_key_for_user(chef), format: :json

        expect(response).to be_success
        expect(existing_morsel.items).to be_empty
      end
    end

    context 'current_user is NOT Morsel creator' do
      it 'should NOT be authorized' do
        delete endpoint, api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'POST /morsels/{:morsel_id}/publish morsels#publish' do
    let(:endpoint) { "/morsels/#{existing_draft_morsel.id}/publish" }

    let(:chef) { FactoryGirl.create(:chef_with_photo) }
    let(:existing_draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: chef, build_feed_item: false, include_mrsl: false) }
    it 'should publish the Morsel by setting draft to false and setting a published_at DateTime' do
      stub_bitly_client

      MorselCollageGeneratorDecorator.any_instance.should_receive(:generate).exactly(1).times.and_return { existing_draft_morsel.update(photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))))}
      Mrsl.should_receive(:shorten).exactly(2).times.and_call_original
      FeedItem.should_receive(:new).exactly(1).times.and_call_original
      FacebookUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
      TwitterUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)

      Sidekiq::Testing.inline! {
        post endpoint,  api_key: api_key_for_user(chef),
                        format: :json
      }

      expect(response).to be_success

      expect(json_data['draft']).to eq(false)
      new_morsel = Morsel.find(existing_draft_morsel.id)
      expect(new_morsel.draft).to eq(false)
    end

    it 'should set the primary_item_id of the Morsel if passed' do
      post endpoint,  api_key: api_key_for_user(chef),
                      morsel: { primary_item_id: existing_draft_morsel.items.first.id },
                      format: :json

      expect(response).to be_success

      expect(json_data['primary_item_id']).to eq(existing_draft_morsel.items.first.id)
      new_morsel = Morsel.find(existing_draft_morsel.id)
      expect(new_morsel.primary_item_id).to eq(existing_draft_morsel.items.first.id)
    end

    context 'post_to_facebook included in parameters' do
      let(:chef_with_facebook_authorization) { FactoryGirl.create(:chef_with_facebook_authorization) }
      let(:existing_draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: chef_with_facebook_authorization, build_feed_item: false, include_mrsl: false) }

      it 'posts to Facebook' do
        stub_facebook_client
        stub_bitly_client

        MorselCollageGeneratorDecorator.any_instance.should_receive(:generate).exactly(1).times.and_return { existing_draft_morsel.update(photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))))}
        Mrsl.should_receive(:shorten).exactly(2).times.and_call_original
        FeedItem.should_receive(:new).exactly(1).times.and_call_original
        FacebookUserDecorator.any_instance.should_receive(:post_facebook_photo_url).exactly(1).times.and_call_original
        TwitterUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)

        Sidekiq::Testing.inline! {
          post endpoint,  api_key: api_key_for_user(chef_with_facebook_authorization),
                          format: :json,
                          post_to_facebook: true
        }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
      end
    end

    context 'post_to_twitter included in parameters' do
      let(:chef_with_twitter_authorization) { FactoryGirl.create(:chef_with_twitter_authorization) }
      let(:existing_draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: chef_with_twitter_authorization, build_feed_item: false, include_mrsl: false) }

      it 'posts a Tweet' do
        stub_twitter_client
        stub_bitly_client

        MorselCollageGeneratorDecorator.any_instance.should_receive(:generate).exactly(1).times.and_return { existing_draft_morsel.update(photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))))}
        Mrsl.should_receive(:shorten).exactly(2).times.and_call_original
        FeedItem.should_receive(:new).exactly(1).times.and_call_original
        FacebookUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
        TwitterUserDecorator.any_instance.should_receive(:post_twitter_photo_url).exactly(1).times.and_call_original

        Sidekiq::Testing.inline! {
          post endpoint,  api_key: api_key_for_user(chef_with_twitter_authorization),
                          format: :json,
                          post_to_twitter: true
        }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
      end
    end
  end

  describe 'GET /morsels/drafts morsels#drafts' do
    let(:endpoint) { '/morsels/drafts' }
    let(:morsels_count) { 3 }
    let(:draft_morsels_count) { rand(3..6) }

    before do
      morsels_count.times { FactoryGirl.create(:morsel_with_items, items_count: items_count) }
      draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: turd_ferg) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:user) { FactoryGirl.create(:user) }
      let(:paginateable_object_class) { Morsel }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:draft_morsel_with_items, creator: user) }
      end
    end

    it 'returns the authenticated User\'s Morsel Drafts' do
      get endpoint, api_key: api_key_for_user(turd_ferg),
                    format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(draft_morsels_count)

      first_morsel = json_data.first

      expect(first_morsel['draft']).to be_true

      expect(first_morsel['creator']).to_not be_nil
    end

    it 'returns morsel_id, sort_order, and url for each Item' do
      get endpoint, api_key: api_key_for_user(turd_ferg),
                    format: :json

      expect(response).to be_success
      first_item = json_data.first['items'].first
      expect(first_item['morsel_id']).to_not be_nil
      expect(first_item['sort_order']).to_not be_nil
      expect(first_item['url']).to_not be_nil
    end
  end
end
