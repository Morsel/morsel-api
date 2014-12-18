require_relative '_spec_helper'

describe 'GET /places/:id/collections' do
  let(:endpoint) { "/places/#{place_with_collections.id}/collections" }
  let(:collections_count) { 3 }
  let(:place_with_collections) { FactoryGirl.create(:place_with_collections, collections_count: collections_count) }

  it_behaves_like 'PagePaginateable' do
    let(:paginateable_object_class) { Collection }

    before do
      paginateable_object_class.delete_all
      30.times { FactoryGirl.create(:collection, place: place_with_collections) }
    end
  end

  it 'returns all of the User\'s Collections' do
    get_endpoint

    expect_success

    expect_json_data_count collections_count
    expect(json_data.first['id']).to eq(Collection.last.id)
  end
end
