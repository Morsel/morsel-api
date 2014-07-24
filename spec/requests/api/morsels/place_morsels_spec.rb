require_relative '_spec_helper'

describe 'GET /places/:id/morsels' do
  let(:endpoint) { "/places/#{place.id}/morsels" }
  let(:place) { FactoryGirl.create(:place) }
  let(:place_morsels_count) { rand(2..6) }

  before do
    place_morsels_count.times { FactoryGirl.create(:morsel_with_creator, place: place) }
  end

  it 'returns Morsels associated with the Place' do
    get_endpoint

    expect_success
    expect_json_data_count place_morsels_count
  end
end
