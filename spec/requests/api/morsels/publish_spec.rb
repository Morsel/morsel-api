require_relative '_spec_helper'

describe 'POST /morsels/{:morsel_id}/publish morsels#publish' do
  let(:endpoint) { "/morsels/#{draft_morsel.id}/publish" }
  let(:current_user) { FactoryGirl.create(:chef_with_photo) }
  let(:draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: current_user, build_feed_item: false, include_mrsl: false) }

  it 'should publish the Morsel by setting draft to false and setting a published_at DateTime' do
    stub_bitly_client

    draft_morsel

    GenerateCollage.any_instance.should_receive(:call).exactly(1).times.and_return { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))}
    ShortenURL.should_receive(:call).exactly(Mrslable.mrsl_sources.count).times.and_call_original
    FeedItem.should_receive(:new).exactly(1).times.and_call_original
    FacebookAuthenticatedUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
    TwitterAuthenticatedUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)

    Sidekiq::Testing.inline! { post_endpoint }

    expect_success

    expect_json_data_eq('draft' => false)

    new_morsel = Morsel.find(draft_morsel.id)
    expect(new_morsel.publishing).to eq(false)
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

  context 'morsel has no title' do
    before { draft_morsel.update title: nil }
    it 'should return an error' do
      Sidekiq::Testing.inline! { post_endpoint }

      expect_failure
      expect(json_errors['title'].first).to eq('is required')
    end
  end

  context 'morsel has no cover set' do
    before { draft_morsel.update primary_item_id: nil }
    it 'should return an error' do
      Sidekiq::Testing.inline! { post_endpoint }

      expect_failure
      expect(json_errors['cover_photo'].first).to eq('is required')
    end
  end

  context 'morsel has tagged Users' do
    let(:tagged_user) { Sidekiq::Testing.inline! { FactoryGirl.create(:user) }}

    before { Sidekiq::Testing.inline! { FactoryGirl.create(:morsel_user_tag, user: tagged_user, morsel: draft_morsel) }}

    it 'should notify them of the published morsel' do
      stub_bitly_client

      GenerateCollage.any_instance.should_receive(:call).exactly(1).times.and_return { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))}
      ShortenURL.should_receive(:call).exactly(Mrslable.mrsl_sources.count).times.and_call_original
      FeedItem.should_receive(:new).exactly(1).times.and_call_original
      FacebookAuthenticatedUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
      TwitterAuthenticatedUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)
      CreateNotification.any_instance.should_receive(:call).exactly(1).times.and_call_original

      Sidekiq::Testing.inline! { post_endpoint }

      expect_success
      expect_json_data_eq('draft' => false)

      new_morsel = Morsel.find(draft_morsel.id)
      expect(new_morsel.draft).to eq(false)

      activity = current_user.activities.last

      expect(activity).to_not be_nil
      expect(activity.creator).to eq(current_user)
      expect(activity.subject).to eq(draft_morsel)
      expect(activity.action).to eq(MorselUserTag.last)

      notification = tagged_user.notifications.last
      expect(notification).to_not be_nil
      expect(notification.user).to eq(tagged_user)
      expect(notification.payload).to eq(activity)

      expect(notification.message).to eq("#{current_user.full_name} (#{current_user.username}) tagged you in #{draft_morsel.title}".truncate(Settings.morsel.notification_length, separator: ' ', omission: '... '))
    end
  end

  context 'post_to_facebook included in parameters' do
    let(:current_user) { FactoryGirl.create(:chef_with_facebook_authentication) }
    let(:draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: current_user, build_feed_item: false, include_mrsl: false) }

    it 'posts to Facebook' do
      stub_facebook_client
      stub_bitly_client

      GenerateCollage.any_instance.should_receive(:call).exactly(1).times.and_return { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))}
      ShortenURL.should_receive(:call).exactly(Mrslable.mrsl_sources.count).times.and_call_original
      FeedItem.should_receive(:new).exactly(1).times.and_call_original
      FacebookAuthenticatedUserDecorator.any_instance.should_receive(:post_facebook_photo_url).exactly(1).times.and_call_original
      TwitterAuthenticatedUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)

      Sidekiq::Testing.inline! {
        post_endpoint post_to_facebook: true
      }

      expect_success
      expect(json_data['id']).to_not be_nil
    end

    context 'authentication does NOT exist' do
      it 'does NOT crap out'
    end
  end

  context 'post_to_twitter included in parameters' do
    let(:current_user) { FactoryGirl.create(:chef_with_twitter_authentication) }
    let(:draft_morsel) { FactoryGirl.create(:draft_morsel_with_items, creator: current_user, build_feed_item: false, include_mrsl: false) }

    it 'posts a Tweet' do
      stub_twitter_client
      stub_bitly_client

      GenerateCollage.any_instance.should_receive(:call).exactly(1).times.and_return { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))}
      ShortenURL.should_receive(:call).exactly(Mrslable.mrsl_sources.count).times.and_call_original
      FeedItem.should_receive(:new).exactly(1).times.and_call_original
      FacebookAuthenticatedUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
      TwitterAuthenticatedUserDecorator.any_instance.should_receive(:post_twitter_photo_url).exactly(1).times.and_call_original

      Sidekiq::Testing.inline! {
        post_endpoint post_to_twitter: true
      }

      expect_success
      expect(json_data['id']).to_not be_nil
    end

    context 'authentication does NOT exist' do
      it 'does NOT crap out'
    end
  end
end

describe 'POST /morsels/{:morsel_id}/publish morsels#republish' do
  let(:endpoint) { "/morsels/#{published_morsel.id}/republish" }
  let(:current_user) { FactoryGirl.create(:chef_with_photo) }
  let(:published_morsel) { FactoryGirl.create(:morsel_with_items, creator: current_user, build_feed_item: true, include_mrsl: false) }

  it 'should publish the Morsel by setting draft to false and setting a published_at DateTime' do
    stub_bitly_client

    published_morsel

    GenerateCollage.any_instance.should_receive(:call).exactly(1).times.and_return { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))}
    ShortenURL.should_receive(:call).exactly(Mrslable.mrsl_sources.count).times.and_call_original
    FeedItem.should_receive(:new).exactly(1).times.and_call_original
    FacebookAuthenticatedUserDecorator.any_instance.should_not_receive(:post_facebook_photo_url)
    TwitterAuthenticatedUserDecorator.any_instance.should_not_receive(:post_twitter_photo_url)

    existing_feed_item = published_morsel.feed_item

    Sidekiq::Testing.inline! { post_endpoint }

    expect_success

    expect_json_data_eq('draft' => false)

    new_morsel = Morsel.find(published_morsel.id)
    expect(new_morsel.publishing).to eq(false)
    expect(new_morsel.draft).to eq(false)
    expect(new_morsel.feed_item).to_not eq(existing_feed_item)

    expect(existing_feed_item.reload.deleted?).to be_true
  end
end
