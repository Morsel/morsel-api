require_relative '_spec_helper'

describe 'GET /morsels morsels#show' do
  let(:endpoint) { "/morsels/#{morsel_with_items.id}" }
  let(:items_count) { 4 }
  let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

  context 'current_user likes the Morsel' do
    let(:current_user) { FactoryGirl.create(:user) }
    before { Like.create(likeable: morsel_with_items, liker: current_user) }

    it 'returns liked=true' do
      get_endpoint

      expect_success
      expect_json_data_eq('liked' => true)
    end
  end

  it 'returns the Morsel' do
    get_endpoint

    expect_success
    expect_json_data_eq({
      'id' => morsel_with_items.id,
      'title' => morsel_with_items.title,
      'summary' => morsel_with_items.summary,
      'creator_id' => morsel_with_items.creator_id,
      'slug' => morsel_with_items.cached_slug,
      'template_id' => morsel_with_items.template_id,
      'place' => {
        'widget_url' => morsel_with_items.place.widget_url
      },
      'has_tagged_users' => false,
      'tagged_users_count' => 0,
      'liked' => nil,
      'primary_item_photos' => morsel_with_items.primary_item_photos
    })
    expect(json_data['items'].count).to eq(items_count)
  end

  context 'has tagged Users' do
    context 'current_user is tagged' do
      let(:current_user) { FactoryGirl.create(:user) }

      before do
        MorselUserTag.create(morsel: morsel_with_items, user: current_user)
      end

      it 'returns `tagged`=true and `has_tagged_users`=true' do
        get_endpoint

        expect_success
        expect_json_data_eq({
          'id' => morsel_with_items.id,
          'has_tagged_users' => true,
          'tagged_users_count' => 1,
          'tagged' => true
        })
      end
    end
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
    let(:paginateable_key) { :published_at }
    before do
      paginateable_object_class.delete_all
      30.times { FactoryGirl.create(:morsel_with_items, creator: current_user) }
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
    let(:paginateable_key) { :updated_at }
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
