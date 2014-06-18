require 'spec_helper'

describe 'Morsels API' do
  describe 'POST /morsels morsels#create', sidekiq: :inline do
    let(:endpoint) { '/morsels' }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:expected_title) { 'Bake Sale!' }

    context 'non-chef' do
      let(:current_user) { FactoryGirl.create(:user) }
      it 'creates a Morsel' do
        post_endpoint morsel: {
                        title: expected_title
                      }

        expect_success

        new_morsel = Morsel.find json_data['id']
        expect_json_data_eq({
          'id' => new_morsel.id,
          'title' => new_morsel.title,
          'creator_id' => new_morsel.creator_id,
          'title' => expected_title,
        })

        expect(json_data['photos']).to be_nil
        expect(new_morsel.draft).to be_true
      end
    end

    it 'creates a Morsel' do
      post_endpoint morsel: {
                      title: expected_title
                    }

      expect_success

      new_morsel = Morsel.find json_data['id']
      expect_json_data_eq({
        'id' => new_morsel.id,
        'title' => new_morsel.title,
        'creator_id' => new_morsel.creator_id,
        'title' => expected_title,
      })

      expect(json_data['photos']).to be_nil
      expect(new_morsel.draft).to be_true
    end

    context 'place_id is passed' do
      let(:place) { FactoryGirl.create(:place) }

      it 'associates that Morsel with that Place' do
        post_endpoint morsel: {
                        title: expected_title,
                        place_id: place.id
                      }

        expect_success

        new_morsel = Morsel.find json_data['id']
        expect_json_data_eq({
          'id' => new_morsel.id,
          'title' => new_morsel.title,
          'creator_id' => new_morsel.creator_id,
          'title' => expected_title,
          'place_id' => place.id
        })

        expect(json_data['photos']).to be_nil
        expect(new_morsel.draft).to be_true
      end
    end

    context 'draft is set to false' do
      it 'creates a draft Morsel' do
        post_endpoint morsel: {
                        title: expected_title,
                        draft: false
                      }

        expect_success

        new_morsel = Morsel.find json_data['id']
        expect_json_data_eq({
          'id' => new_morsel.id,
          'title' => new_morsel.title,
          'creator_id' => new_morsel.creator_id,
          'title' => expected_title,
        })

        expect(new_morsel.draft).to be_false
      end
    end

    context 'primary_item_id is included' do
      let(:some_item) { FactoryGirl.create(:item_with_creator) }
      it 'should fail since a new Morsel has no Items' do
        post_endpoint morsel: {
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
    let(:items_count) { 4 }
    let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

    it 'returns the Morsel' do
      get_endpoint

      expect_success
      expect_json_data_eq({
        'id' => morsel_with_items.id,
        'title' => morsel_with_items.title,
        'creator_id' => morsel_with_items.creator_id,
        'slug' => morsel_with_items.cached_slug
      })
      expect(json_data['items'].count).to eq(items_count)
    end

    context 'has a photo' do
      let(:endpoint) { "/morsels/#{morsel_with_creator_and_photo.id}" }
      let(:morsel_with_creator_and_photo) { FactoryGirl.create(:morsel_with_creator_and_photo) }

      it 'returns the Morsel with photos' do
        get_endpoint

        expect_success
        expect_json_data_eq({
          'id' => morsel_with_creator_and_photo.id,
          'title' => morsel_with_creator_and_photo.title,
          'creator_id' => morsel_with_creator_and_photo.creator_id
        })

        photos = json_data['photos']
        expect(photos['_800x600']).to_not be_nil
      end
    end
  end

  describe 'PUT /morsels/{:morsel_id} morsels#update' do
    let(:endpoint) { "/morsels/#{existing_morsel.id}" }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_items, creator: current_user) }
    let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

    it 'updates the Morsel' do
      put_endpoint  morsel: {
                      title: new_title
                    }

      expect_success
      expect_json_data_eq({
        'id' => existing_morsel.id,
        'title' => new_title,
        'draft' => false
      })

      new_morsel = Morsel.find(existing_morsel.id)
      expect(new_morsel.title).to eq(new_title)
      expect(new_morsel.draft).to eq(false)
    end

    it 'should set the draft to false when draft=false is passed' do
      existing_morsel.update(draft:true)

      put_endpoint  morsel: {
                      title: new_title,
                      draft: false
                    }

      expect_success
      expect_json_data_eq('draft' => false)

      new_morsel = Morsel.find(existing_morsel.id)
      expect(new_morsel.draft).to eq(false)
    end

    context 'primary_item_id is included' do
      let(:some_item) { FactoryGirl.create(:item_with_creator, morsel: existing_morsel) }
      it 'updates the primary_item_id' do
        put_endpoint  morsel: {
                        title: new_title,
                        primary_item_id: some_item.id
                      }

        expect_success

        new_morsel = Morsel.find json_data['id']
        expect_json_data_eq({
          'id' => new_morsel.id,
          'title' => new_morsel.title,
          'creator_id' => new_morsel.creator_id,
          'primary_item_id' => some_item.id
        })
        expect(new_morsel.primary_item_id).to eq(some_item.id)
      end

      it 'should fail if primary_item_id is not one of the Morsel\'s Items' do
        put_endpoint  morsel: {
                        title: new_title,
                        primary_item_id: FactoryGirl.create(:item).id
                      }

        expect_failure
        expect(json_errors['primary_item'].first).to eq('does not belong to this Morsel')
      end
    end

    context 'current_user is NOT Morsel creator' do
      let(:endpoint) { "/morsels/#{FactoryGirl.create(:morsel_with_items).id}" }
      it 'should NOT be authorized' do
        put_endpoint  morsel: {
                      title: new_title
                    }

        expect_failure
      end
    end
  end

  describe 'DELETE /morsels/{:morsel_id} morsels#destroy' do
    let(:current_user) { FactoryGirl.create(:chef) }

    context 'current_user\'s Morsel' do
      let(:endpoint) { "/morsels/#{morsel.id}" }
      let(:morsel) { FactoryGirl.create(:morsel_with_creator, creator: current_user) }

      it 'soft deletes the Morsel' do
        delete_endpoint

        expect_success
        expect(Morsel.find_by(id: morsel.id)).to be_nil
      end

      it 'soft deletes the Morsel\'s FeedItem' do
        delete_endpoint

        expect_success
        expect(FeedItem.find_by(subject_id: morsel.id, subject_type:morsel.class)).to be_nil
      end

      context 'with Items' do
        let(:morsel) { FactoryGirl.create(:morsel_with_items, creator: current_user) }

        it 'soft deletes all of its Items' do
          delete_endpoint

          expect_success
          expect(morsel.items).to be_empty
        end
      end
    end

    context 'someone else\'s Morsel' do
      let(:endpoint) { "/morsels/#{morsel.id}" }
      let(:morsel) { FactoryGirl.create(:morsel_with_creator, creator: FactoryGirl.create(:user)) }

      it 'should NOT be authorized' do
        delete_endpoint

        expect_failure
      end
    end
  end

  describe 'POST /morsels/{:morsel_id}/publish morsels#publish' do
    let(:endpoint) { "/morsels/#{draft_morsel.id}/publish" }
    let(:current_user) { FactoryGirl.create(:chef_with_photo) }
    let(:draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: current_user, build_feed_item: false, include_mrsl: false) }

    it 'should publish the Morsel by setting draft to false and setting a published_at DateTime' do
      stub_bitly_client

      MorselCollageGeneratorDecorator.any_instance.should_receive(:generate).exactly(1).times.and_return { draft_morsel.update(photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))))}
      Mrsl.should_receive(:shorten).exactly(2).times.and_call_original
      FeedItem.should_receive(:new).exactly(1).times.and_call_original
      FacebookAuthenticatedUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
      TwitterAuthenticatedUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)

      Sidekiq::Testing.inline! { post_endpoint }

      expect_success
      expect_json_data_eq('draft' => false)

      new_morsel = Morsel.find(draft_morsel.id)
      expect(new_morsel.draft).to eq(false)
    end

    it 'should set the primary_item_id of the Morsel if passed' do
      post_endpoint morsel: {
                      primary_item_id: draft_morsel.items.first.id
                    }

      expect_success
      expect_json_data_eq('primary_item_id' => draft_morsel.items.first.id)

      new_morsel = Morsel.find(draft_morsel.id)
      expect(new_morsel.primary_item_id).to eq(draft_morsel.items.first.id)
    end

    context 'post_to_facebook included in parameters' do
      let(:current_user) { FactoryGirl.create(:chef_with_facebook_authentication) }
      let(:draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: current_user, build_feed_item: false, include_mrsl: false) }

      it 'posts to Facebook' do
        stub_facebook_client
        stub_bitly_client

        MorselCollageGeneratorDecorator.any_instance.should_receive(:generate).exactly(1).times.and_return { draft_morsel.update(photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))))}
        Mrsl.should_receive(:shorten).exactly(2).times.and_call_original
        FeedItem.should_receive(:new).exactly(1).times.and_call_original
        FacebookAuthenticatedUserDecorator.any_instance.should_receive(:post_facebook_photo_url).exactly(1).times.and_call_original
        TwitterAuthenticatedUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)

        Sidekiq::Testing.inline! {
          post_endpoint post_to_facebook: true
        }

        expect_success
        expect(json_data['id']).to_not be_nil
      end
    end

    context 'post_to_twitter included in parameters' do
      let(:current_user) { FactoryGirl.create(:chef_with_twitter_authentication) }
      let(:draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: current_user, build_feed_item: false, include_mrsl: false) }

      it 'posts a Tweet' do
        stub_twitter_client
        stub_bitly_client

        MorselCollageGeneratorDecorator.any_instance.should_receive(:generate).exactly(1).times.and_return { draft_morsel.update(photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))))}
        Mrsl.should_receive(:shorten).exactly(2).times.and_call_original
        FeedItem.should_receive(:new).exactly(1).times.and_call_original
        FacebookAuthenticatedUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
        TwitterAuthenticatedUserDecorator.any_instance.should_receive(:post_twitter_photo_url).exactly(1).times.and_call_original

        Sidekiq::Testing.inline! {
          post_endpoint post_to_twitter: true
        }

        expect_success
        expect(json_data['id']).to_not be_nil
      end
    end
  end

  describe 'GET /morsels' do
    let(:endpoint) { '/morsels' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:morsels_count) { 3 }
    let(:draft_morsels_count) { rand(3..6) }

    before do
      morsels_count.times { FactoryGirl.create(:morsel_with_items, creator: current_user) }
      draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: current_user) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Morsel }
      before do
        paginateable_object_class.delete_all
        15.times { FactoryGirl.create(:morsel_with_items, creator: current_user) }
        15.times { FactoryGirl.create(:draft_morsel_with_items, creator: current_user) }
      end
    end

    it 'returns the authenticated User\'s Morsels, including Drafts' do
      get_endpoint

      expect_success
      expect_json_data_count morsels_count + draft_morsels_count
    end
  end

  describe 'GET /morsels/drafts morsels#drafts' do
    let(:endpoint) { '/morsels/drafts' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:morsels_count) { 3 }
    let(:draft_morsels_count) { rand(3..6) }
    let(:items_count) { 4 }

    before do
      morsels_count.times { FactoryGirl.create(:morsel_with_items, items_count: items_count, creator: current_user) }
      draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: current_user) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Morsel }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:draft_morsel_with_items, creator: current_user) }
      end
    end

    it 'returns the authenticated User\'s Morsel Drafts' do
      get_endpoint

      expect_success
      expect_json_data_count draft_morsels_count
      expect_first_json_data_eq({
        'draft' => true
      })
    end

    it 'returns morsel_id, sort_order, and url for each Item' do
      get_endpoint

      expect_success

      first_item = json_data.first['items'].first
      expect(first_item['morsel_id']).to_not be_nil
      expect(first_item['sort_order']).to_not be_nil
      expect(first_item['url']).to_not be_nil
    end
  end
end
