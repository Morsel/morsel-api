require_relative '_spec_helper'

describe 'POST /users/devices' do
  let(:endpoint) { '/users/devices' }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:name) { "#{Faker::Name.name}'s Device" }
  let(:token) { Faker::Lorem.characters(32) }
  let(:model) { 'iphone' }

  it 'creates a new device' do
    post_endpoint device: {
                    name: name,
                    token: token,
                    model: model
                  }

    expect_success
    expect_json_data_eq({
      'name' => name,
      'token' => token,
      'model' => model,
      'user_id' => current_user.id
    })
  end
end
