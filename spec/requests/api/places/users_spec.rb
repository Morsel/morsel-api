require_relative '_spec_helper'

describe 'GET /places/:id/users places#users' do
  let(:endpoint) { "/places/#{place.id}/users" }
  let(:place) { FactoryGirl.create(:place) }
  let(:place_users_count) { rand(2..6) }

  before do
    place_users_count.times { FactoryGirl.create(:employment, place: place) }
  end

  it 'returns Users associated with the Place' do
    get_endpoint

    expect_success

    expect_json_data_count place_users_count

    expect_first_json_data_eq title: Employment.last.title
  end
end
