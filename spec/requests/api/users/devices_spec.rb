require_relative '_spec_helper'

describe 'GET /users/devices devices#index' do
  let(:endpoint) { '/users/devices' }
  let(:current_user) { nil }

  context 'valid current_user' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:device_count) { rand(2..6) }

    before do
      device_count.times { FactoryGirl.create(:device, user: current_user) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Device }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:device, user: current_user) }
      end
    end

    it 'returns the current_user\'s Devices' do
      get_endpoint

      expect_success
      expect(json_data.count).to eq(device_count)
    end
  end

  it 'returns an unauthorized error' do
    get_endpoint api_key: '1:234567890'

    expect_failure
    expect_status 401
  end
end

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

describe 'DELETE /users/devices/:id devices#destroy' do
  let(:endpoint) { "/users/devices/#{existing_device.id}"}
  let(:current_user) { FactoryGirl.create(:user) }
  let(:existing_device) { FactoryGirl.create(:device, user: current_user) }

  it 'deletes the device' do
    delete_endpoint

    expect_success
    expect(Device.find_by(id: existing_device.id)).to be_nil
  end
end
