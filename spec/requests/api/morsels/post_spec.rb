require_relative '_spec_helper'

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
