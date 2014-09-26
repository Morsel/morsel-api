require_relative '_spec_helper'

describe 'GET /users/:id|:username/morsels' do
  let(:endpoint) { "/users/#{user_with_morsels.id}/morsels" }
  let(:morsels_count) { 3 }
  let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels, morsels_count: morsels_count) }

  it_behaves_like 'TimelinePaginateable' do
    let(:paginateable_object_class) { Morsel }
    let(:paginateable_key) { :published_at }
    before do
      paginateable_object_class.delete_all
      30.times { FactoryGirl.create(:morsel_with_items, creator: user_with_morsels) }
    end
  end

  it 'returns all of the User\'s Morsels' do
    get_endpoint

    expect_success

    expect_json_data_count user_with_morsels.morsels.count
  end

  context 'has drafts' do
    let(:draft_morsels_count) { rand(3..6) }
    before do
      draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: user_with_morsels) }
    end

    it 'should NOT include drafts' do
      get_endpoint

      expect_success

      expect_json_data_count morsels_count
    end
  end

  context 'has tagged morsels' do
    let(:tagged_morsels_count) { rand(3..6) }

    before { tagged_morsels_count.times { FactoryGirl.create(:morsel_tagged_user, user: user_with_morsels) }}

    it 'should include tagged morsels' do
      get_endpoint

      expect_success

      expect_json_data_count morsels_count + tagged_morsels_count
    end
  end

  context 'username passed instead of id' do
    let(:endpoint) { "/users/#{user_with_morsels.username}/morsels" }
    it 'returns all of the User\'s Morsels' do
      get_endpoint

      expect_success

      expect_json_data_count user_with_morsels.morsels.count
    end
  end
end
