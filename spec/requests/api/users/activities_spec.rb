require_relative '_spec_helper'

describe 'GET /users/activities' do
  let(:endpoint) { '/users/activities' }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:items_count) { 3 }
  let(:some_morsel) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

  before do
    if current_user
      some_morsel.items.each do |item|
        Sidekiq::Testing.inline! { item.likers << current_user }
      end
    end
  end

  it_behaves_like 'TimelinePaginateable' do
    let(:paginateable_object_class) { Activity }
    before do
      paginateable_object_class.delete_all
      30.times { FactoryGirl.create(:item_like_activity, creator_id: current_user.id) }
    end
  end

  it 'returns the User\'s recent activities' do
    get_endpoint

    expect_success
    expect_json_data_count items_count

    last_item = some_morsel.items.last
    last_item_creator = last_item.creator
    last_item_morsel = last_item.morsel

    expect_first_json_data_eq({
      'action_type' => 'Like',
      'subject_type' => 'Item',
      'subject' => {
        'id' => last_item.id,
        'description' => last_item.description,
        'nonce' => last_item.nonce,
        'creator' => {
          'id' => last_item_creator.id,
          'username' => last_item_creator.username,
          'first_name' => last_item_creator.first_name,
          'last_name' => last_item_creator.last_name
        },
        'morsel' => {
          'id' => last_item_morsel.id,
          'title' => last_item_morsel.title,
          'slug' => last_item_morsel.slug
        }
      }
    })
  end

  context 'subject is deleted' do
    before do
      Like.last.destroy
    end

    it 'removes the Activity' do
      get_endpoint

      expect_success
      expect_json_data_count(items_count - 1)
    end
  end

  context 'invalid api_key' do
    let(:current_user) { nil }
    it 'returns an unauthorized error' do
      get_endpoint api_key: '1:234567890'

      expect_failure
      expect_status 401
    end
  end
end

describe 'GET /users/followables_activities' do
  let(:endpoint) { '/users/followables_activities' }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:followed_users) { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
  let(:items_count) { 3 }
  let(:some_morsel) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

  before do
    followed_users.each do |fu|
      current_user.followed_users << fu
    end

    some_morsel.items.each do |item|
      Sidekiq::Testing.inline! { item.likers << followed_users.sample }
    end
  end

  it_behaves_like 'TimelinePaginateable' do
    let(:paginateable_object_class) { Activity }
    before do
      paginateable_object_class.delete_all
      30.times { FactoryGirl.create(:item_like_activity, creator_id: followed_users.sample.id) }
    end
  end

  it 'returns the User\'s Followed Users\' recent activities' do
    get_endpoint

    expect_success
    expect_json_data_count items_count

    last_item = some_morsel.items.last
    expect_first_json_data_eq({
      'action_type' => 'Like',
      'subject_type' => 'Item',
      'subject' => {
        'id' => last_item.id,
        'description' => last_item.description,
        'nonce' => last_item.nonce
      }
    })
  end

  context 'subject is deleted' do
    before do
      Like.last.destroy
    end

    it 'removes the Activity' do
      get_endpoint

      expect_success
      expect_json_data_count(items_count - 1)
    end
  end
end
