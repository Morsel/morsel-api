require_relative '_spec_helper'

describe 'GET /users/:id/places' do
  let(:endpoint) { "/users/#{user.id}/places" }
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:user) { FactoryGirl.create(:user) }
  let(:place_count) { rand(2..6) }

  before do
    place_count.times { FactoryGirl.create(:employment, user: user) }
  end

  it 'returns Places associated with the User' do
    get_endpoint

    expect_success
    expect_json_data_count place_count

    expect_first_json_data_eq title: Employment.last.title
  end
end
