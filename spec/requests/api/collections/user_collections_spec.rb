require_relative '_spec_helper'

describe 'GET /users/:id/collections' do
  let(:endpoint) { "/users/#{user_with_collections.id}/collections" }
  let(:collections_count) { 3 }
  let(:user_with_collections) { FactoryGirl.create(:user_with_collections, collections_count: collections_count) }

  it_behaves_like 'TimelinePaginateable' do
    let(:paginateable_object_class) { Collection }

    before do
      paginateable_object_class.delete_all
      30.times { FactoryGirl.create(:collection, user: user_with_collections) }
    end
  end

  it 'returns all of the User\'s Collections' do
    get_endpoint

    expect_success

    expect_json_data_count collections_count
  end
end
